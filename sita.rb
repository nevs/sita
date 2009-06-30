#!/usr/bin/env ruby

require 'rexml/document'
require 'pathfinder'


module Sita

  DEBUG = false

  class Function
    attr_reader :name, :xml, :datums, :body

    def initialize( xml_file )
      @xml = REXML::Document.new( File.new( xml_file ), {:ignore_whitespace_nodes=>:all} )
      @name = xml.elements['//Function/@name'].to_s
      @datums = xml.elements['//Function/datums']
      @body = xml.elements['//Function/action/Block']
    end
  end


  module Tests
    
    class SQL_Injection
      attr_reader :function
      def initialize( function )
        @function = function
      end
      
      def run
        function.xml.each_element('//DynamicExecute') do | dyn_exec |

          # get node containing the expression that gets executed
          node = dyn_exec.elements['query/Expression/SQLParseTree/sql:SelectStatement/sql:TargetList/sql:ResultTarget/*']

          begin
            if not sql_node_safe?( dyn_exec, node )
              puts "DynamicExecute `#{dyn_exec.elements['query/Expression/@query']}`: unsafe"
            end
#          rescue
#            puts "unsure"
          end

        end
      end

      def sql_node_safe?( dyn_exec, node )
        puts "node_safe?: #{node.inspect}" if DEBUG
        case node.name
          when "Constant" then return true
          when "Expression" then return sql_expression_safe?( dyn_exec, node )
          when "ParameterReference" then return parameter_safe?( dyn_exec, node )
#          when "FunctionCall" then return function_safe?( dyn_exec, node )
          else
          puts "Unknown node: #{node.name}"
          raise "Unknown node: #{node.name}"
        end
        false
      end

      def parameter_safe?( dyn_exec, node )
        puts "parameter_safe?: #{node.inspect}" if DEBUG
        local_index = Integer(node.text)
        datum_index = Integer(dyn_exec.elements["query/Expression/parameters/*[#{local_index}]"].text)
        datum = function.datums.elements["*[@dno = '#{datum_index}']"]
        if datum.attribute("name").to_s.match(/^\$\d+$/)
          # parameter is a function argument which is considered unsafe
          false
        else
          # normal variable which we have to backtrace to be sure
          PathFinder.run( function.body, dyn_exec ).each do | path |
            if backtrace_parameter( path, datum )
              next
            else
              return false
            end  
          end
          true
        end
      end

      def backtrace_parameter( path, parameter )
        return true
        path.each do | node |
          case node.name
            when "Assignment" then
              if function.datums.elements["*[#{node.elements['parameter/text()']}]"] == parameter
                # this is the parameter we are interested in
                if not sql_node_safe?( node, node.elements['expression/Expression/SQLParseTree/sql:SelectStatement/sql:TargetList/sql:ResultTarget/*'] )
                  puts "Unsafe Assignment"
                  return false
                end
              end
            when "DynamicExecute" then
              # node = dyn_exec.elements['query/Expression/SQLParseTree/sql:SelectStatement/sql:TargetList/sql:ResultTarget/*']
              return false
            else
              raise "Unknown node in backtrace_parameter: #{node.inspect}"

          end
        end
        true
      end

      def find_index( list, node )
        list.each_with_index do | list_node, index |
          return index + 1 if list_node == node
        end
        raise "node not in list"
      end

      def function_safe?( dyn_exec, node )
        name = node.elements['function_name/text()'].to_s
        case name
          when 'quote_ident','quote_literal','quote_nullable' then true
          else false
        end
      end

      def sql_expression_safe?( dyn_exec, node )
        puts "sql_expression_safe?: #{node.inspect}" if DEBUG
        name = node.elements['sql:Operator'].attribute('name').to_s
        type = node.elements['sql:Operator'].attribute('type').to_s
        case type
          when "normal" then
            case name
              when "||"
                sql_node_safe?( dyn_exec, node.elements['left/*'] ) && sql_node_safe?( dyn_exec, node.elements['right/*'] )
              else
                raise "Unhandled expression type"
                false
            end
          else
            raise "Unhandled expression type"
            false
        end
      end

    end

  end
end

xml_file = "vuln_sql_injection_direct.xml" || ARGV[0]

function = Sita::Function.new( xml_file )

Sita::Tests::SQL_Injection.new( function ).run

