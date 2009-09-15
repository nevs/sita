#!/usr/bin/env ruby

require 'rexml/document'
require 'pathfinder'
require 'test/unit/assertions'
require 'yaml'


module Sita

  DEBUG = false

  class Function
    attr_reader :name, :xml, :datums, :body, :config

    def initialize( xml_string )
      @xml = REXML::Document.new( xml_string, {:ignore_whitespace_nodes=>:all} )
      @name = xml.elements['//Function/@name'].to_s
      @datums = xml.elements['//Function/datums']
      @body = xml.elements['//Function/action/Block']
      @config = YAML.load_file('sita.yml')
    end
  end


  module Tests
    
    class SQL_Injection
      include Test::Unit::Assertions

      attr_reader :function
      def initialize( function )
        @function = function
      end
      
      def run
        puts "\nStarting analysis of function #{function.name}\n\n"
        safe = true
        function.xml.each_element('//DynamicExecute|//DynamicForS') do | context |

          if not plpgsql_expression_safe?( context, context.elements['query/Expression'])
            safe = false
            puts "SQL injection vulnerability found in #{context.name} on line #{context.attribute('line')}"
          end

        end

        function.xml.each_element('//ReturnQuery') do | context |
          # ReturnQuery may have a static query or a dynamic one
          # we only need to check dynamic queries
          if context.elements['dynquery']

            if not plpgsql_expression_safe?( context, context.elements['dynquery/Expression'])
              safe = false
              puts "SQL injection vulnerability found in #{context.name} on line #{context.attribute('line')}"
            end

          end
        end

        if safe
          puts "\nFunction #{function.name} is safe.\n"
        else
          puts "\nFunction #{function.name} is unsafe.\n"
        end
      end

      # @context: plpgsql statement containing the node
      # @expression: current plpgsql expression node is child of
      # @node: sql node to be inspected
      def sql_node_safe?( context, expression, node )
        puts "sql_node_safe?: #{node.inspect}" if DEBUG
        case node.name
          when "ColumnReference" then return false
          when "Constant" then return true
          when "Expression" then return sql_expression_safe?( context, expression, node )
          when "ParameterReference" then 
            # resolve local parameter reference
            dno = expression.elements['parameters/*[#{node.text.to_s}]'].text.to_s
            datum = function.datums.elements["*[@dno = '#{dno}']"]
            return plpgsql_parameter_safe?( context, datum )
          when "FunctionCall" then return function_safe?( context, node )
          else
          raise "Unknown node: #{node.name}"
        end
        false
      end

      # @context: plpgsql statement
      # @parameter: plpgsql datum node to be inspected
      def plpgsql_parameter_safe?( context, parameter )
        puts "plpgsql_parameter_safe?: #{parameter.inspect}" if DEBUG

        if parameter.name != "Variable"
          raise "Tracking #{parameter.name} not supported."
        end

        # check datatype of parameter
        case parameter.attribute('datatype').to_s
          when 'integer','boolean'
            # these datatypes are always considered safe since they cannot include compromising values
            return true

        end
        
        if parameter.attribute("name").to_s.match(/^\$\d+$/)
          # parameter is a function argument which is considered unsafe
          return false
        else
          result = true
          # normal variable which we have to backtrace to be sure
          PathFinder.run( function.body, context ).each do | path |
            result &&= parameter_path_safe?( path, parameter )
          end
          return result
        end
      end

      def parameter_path_safe?( path, parameter )
        puts "parameter_path_safe?: #{parameter.inspect}" if DEBUG
        path.each do | node |
          case node.name
            when "Assignment" then
              if function.datums.elements["*[@dno = '#{node.elements['parameter/text()']}']"] == parameter
                # this is the parameter we are interested in
                if not plpgsql_expression_safe?( node, node.elements['expression/Expression'])
                  return false
                else
                  # don't need to backtrace any further
                  return true
                end
              end
            when "DynamicExecute","ExecuteSQL" then
              # check if the results get put in the parameter we are currently checking
              if node.elements['into']
                if node.elements["into/Row/fields/Field[@dno='#{parameter.attribute('dno')}']"]
                  # this is the parameter we are interested in
                  return plpgsql_expression_safe?( node, node.elements['query/Expression'])
                end
              end
              return true
            when "DynamicForS", "ForS" then
              if node.elements["row/Row/fields/Field[@dno='#{parameter.attribute('dno')}']"]
                # this is the parameter we are interested in
                return plpgsql_expression_safe?( node, node.elements['query/Expression'])
              end
            when "Fetch"
              if node.elements["row/Row/fields/Field[@dno='#{parameter.attribute('dno')}']"]
                # this is the parameter we are interested in
                raise "Implement cursor checking"
              end
              return false
            when "Return","ReturnQuery" then
              # path does not reach the offending usage of the parameter
              return true
            when "Block","Case","Close","GetDiagnostics","Exit","ForI","ForC","If","Loop","Perform","Raise","ReturnNext","While" then
              # nothing to do for these nodes
            else
              raise "Unknown node in backtrace_parameter: #{node.inspect}"

          end
        end
        # parameter got not initialized if we end up here
        # check for default value
        if parameter.elements['default_value']
          plpgsql_expression_safe?( parameter, parameter.elements['default_value/Expression'])
        end

        # parameter got not initialized which translates to NULL
        # which is considered safe
        true
      end

      def plpgsql_expression_safe?( context, expression )
        puts "plpgsql_expression_safe?: #{expression.inspect}" if DEBUG
        sql_node_safe?( context, expression, expression.elements['SQLParseTree/sql:SelectStatement/sql:TargetList/sql:ResultTarget/*'] )
      end

      def function_safe?( context, node )
        name = node.elements['function_name/text()'].to_s
        function.config['safe_escape_functions'].member?( name )
      end

      def sql_expression_safe?( context, expression, node )
        puts "sql_expression_safe?: #{node.inspect}" if DEBUG
        name = node.elements['sql:Operator'].attribute('name').to_s
        type = node.elements['sql:Operator'].attribute('type').to_s
        case type
          when "normal" then
            case name.gsub(/(&#10;| )+/,'')
              when "||"
                sql_node_safe?( context, expression, node.elements['left/*'] ) && 
                sql_node_safe?( context, expression, node.elements['right/*'] )
              else
                raise "Unhandled expression type: #{name}"
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

