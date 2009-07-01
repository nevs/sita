
module Sita
  class PathFinder

    def self.run( root, node )
      pathes = []
      PathFinder.find( root, node, [] ) do | path |
        pathes << path
        p path
      end
      puts "Pathes found: #{pathes.length}"
      pathes
    end

    protected

    # returns a list of all pathes from node to root
    def self.find( root, node, path = [], &block )

      # collect previous nodes of the current block and add them to the path
      previous_nodes = node.parent.children

      while previous_nodes.pop != node do
        # remove all nodes after current node
      end

      #puts "previous_nodes: #{previous_nodes.inspect}"

      previous_nodes.reverse_each do | cur_node |
        #puts "Cur_node: #{cur_node.inspect}"
        case cur_node.name
          when "Block", "DynamicForS", "ForC", "ForI", "ForS", "Loop", "While" then
            path << cur_node.elements['body'].children.last || cur_node
            find( root, path.last, path, &block )
            return
          when "If" then
            true_path = path.dup
            true_path << cur_node.elements['true_body'].children.last || cur_node
            find( root, true_path.last, true_path, &block )
            false_path = path.dup
            false_path << cur_node.elements['false_body'].children.last || cur_node
            find( root, false_path.last, false_path, &block )
            return
          when "Case" then
            cur_node.elements['case_when_list'].children.each do | case_when |
              cur_path = path.dup
              cur_path << case_when.elements['statements'].children.last || cur_node
              find( root, cur_path.last, cur_path, &block )
            end
            if cur_node.elements['else_statements']
              path << cur_node.elements['else_statements'].children.last || cur_node
            else
              path << cur_node
            end
            find( root, path.last, path, &block )
            return
          when "Assignment","Close","DynamicExecute","ExecuteSQL","Exit","Fetch","GetDiagnostics","Open","Perform","Raise","Return","ReturnNext","ReturnQuery" then
            # nothing to do here
            path << cur_node
          else
            raise "Unknown node type in Pathfinder: #{cur_node.name}"
        end
      end
      
      if node.parent.parent == root
        # finished backtracing
        yield path
      else
        # backtrace further
        case node.parent.parent.name
          when "CaseWhen" then
            path << node.parent.parent.parent.parent
          else
            path << node.parent.parent
        end
        find( root, path.last, path.dup, &block )
      end

    end

  end
end

