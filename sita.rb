#!/usr/bin/env ruby

require 'rexml/document'


module Sita

  class Function
    attr_reader :name, :xml

    def initialize( xml_file )
      @xml = REXML::Document.new( File.new( xml_file ), {:ignore_whitespace_nodes=>:all} )
      @name = xml.elements['//Function/@name'].to_s
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
          puts "Evaluating DynamicExecute `#{dyn_exec.elements['query/Expression/@query']}`"

          # get node containing the expression that gets executed
          node = dyn_exec.elements['query/Expression/sql_parse_tree/SelectStatement/TargetList/ResultTarget/*']

          if not node_safe?( node )
            puts "Vulnerability found in #{function.name}"
          end


          puts ""
        end
      end

      def node_safe?( node )
        case node.name
          when "Constant" then return true
          when "Expression" then return expression_safe?( node )
          when "ParameterReference" then return false
          else
          puts "Unknown node: #{node.name}"
        end
        false
      end

      def expression_safe?( node )
        name = node.elements['Operator'].attribute('name').to_s
        type = node.elements['Operator'].attribute('type').to_s
        case type
          when "normal" then
            case name
              when "||"
                return node_safe?( node.elements['left/*'] ) && node_safe?( node.elements['right/*'] )
            end
        end
        puts node
      end

    end

  end
end

xml_file = "vuln_sql_injection_direct.xml" || ARGV[0]

function = Sita::Function.new( xml_file )

Sita::Tests::SQL_Injection.new( function ).run
