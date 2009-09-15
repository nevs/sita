#!/bin/env ruby

require 'rubygems'
require 'sita'
require 'open3'
require 'postgres'
require 'rexml/document'

conn = PGconn.open('port'=>'5433','host'=>'localhost')

sql = File.new( ARGV[0] || "test.sql" ).read

# parse sql statements of file
xml = conn.exec("SELECT dump_sql_parse_tree($1);", sql )[0][0]

# run sql file
conn.exec( sql ) 

# puts xml


xml = REXML::Document.new( xml, {:ignore_whitespace_nodes=>:all} )

xml.each_element('//CreateFunctionStmt') do | function |

  func_name = []
  arguments = []
  
  function.each_element('funcname/List/String/value') do | name |
    func_name << name.text
  end
  
  function.each_element('parameters/List/FunctionParameter/argType/TypeName/names/List') do | arg |
    names = []
    arg.each_element('String/value') do | name |
      names << name.text
    end
    arguments << names.join('.')
  end
  
  ast = conn.exec("SELECT dump_plpgsql_function(#{conn.quote("#{func_name.join('.')}(#{arguments.join(',')})")}::regprocedure);")[0][0]
  
  stdin, stdout, stderr = Open3.popen3("xsltproc ../rama/plpgsql_function.xsl -")
  stdin.write( ast )
  stdin.close
  
  transformed_ast = stdout.read
  
  function = Sita::Function.new( transformed_ast )
  
  Sita::Tests::SQL_Injection.new( function ).run

end

