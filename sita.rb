#!/usr/bin/env ruby

require 'rexml/document'


module Sita

  class Function
    attr_reader :name, :xml, :datums

    def initialize( xml_file )
      @xml = REXML::Document.new( File.new( xml_file ), {:ignore_whitespace_nodes=>:all} )
      @name = xml.elements['//Function/@name'].to_s
      @datums = xml.elements['//Function/datums']
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
          printf "Evaluating DynamicExecute `#{dyn_exec.elements['query/Expression/@query']}`: "

          # get node containing the expression that gets executed
          node = dyn_exec.elements['query/Expression/sql_parse_tree/SelectStatement/TargetList/ResultTarget/*']

          begin
            if not node_safe?( dyn_exec, node )
              puts "unsafe"
            else
              puts "safe"
            end
#          rescue
#            puts "unsure"
          end


          puts ""
        end
      end

      def node_safe?( dyn_exec, node )
        case node.name
          when "Constant" then return true
          when "Expression" then return expression_safe?( dyn_exec, node )
          when "ParameterReference" then parameter_safe?( dyn_exec, node )
          when "FunctionCall" then return function_safe?( dyn_exec, node )
          else
          puts "Unknown node: #{node.name}"
          raise "Unknown node"
        end
        false
      end

      def parameter_safe?( dyn_exec, node )
        puts "\n\n"
        local_index = Integer(node.text)
        datum_index = Integer(dyn_exec.elements["query/Expression/parameters/*[#{local_index}]"].text)
        datum = function.datums.elements["*[#{datum_index}]"]
        if datum.attribute("name").to_s.match(/^\$\d+$/)
          # parameter is a function argument which is considered unsafe
          false
        else
          # normal variable which we have to backtrace to be sure
          # FIXME add code for backtracing
          puts datum
        end
      end

      def function_safe?( dyn_exec, node )
        name = node.elements['function_name/text()'].to_s
        case name
          when 'quote_ident','quote_literal' then true
          else false
        end
      end

      def expression_safe?( dyn_exec, node )
        name = node.elements['Operator'].attribute('name').to_s
        type = node.elements['Operator'].attribute('type').to_s
        case type
          when "normal" then
            case name
              when "||"
                node_safe?( dyn_exec, node.elements['left/*'] ) && node_safe?( dyn_exec, node.elements['right/*'] )
            end
          else
            puts node
            false
        end
      end

    end

  end
end

xml_file = "vuln_sql_injection_direct.xml" || ARGV[0]

function = Sita::Function.new( xml_file )

Sita::Tests::SQL_Injection.new( function ).run

