module Docs
  class Go
    class UsagesFilter < Filter
      def call
        # Add examples link to every type and non-constructor function
        css('h2').each do |node|
          if node.text.start_with?('type ') or node.text.start_with?('func ')
            name = node.attr("id")
            node.add_next_sibling("<a href=\"#{usages_url(name)}\">Examples</a>")
          end
        end

        # Add examples link to every method and constructor function
        css('h3').each do |node|
          if node.text.start_with?('func ')
            name = node.attr("id").gsub(".", "/")
            node.add_next_sibling("<a href=\"#{usages_url(name)}\">Examples</a>")
          end
        end

        # Add examples link to every package variable
        css('h2#pkg-variables').each do |var_header_node|
          var_nodes = []
          cur_node = var_header_node.next_element
          while cur_node != nil
            if cur_node.name == 'h2'
              break
            end
            if cur_node.name == 'pre'
              var_nodes.push(cur_node)
            end
            cur_node = cur_node.next_element
          end
          var_nodes.each do |node|
            if node.name == "pre"
              node.text.scan(/^\s*(?:var\s+)?([A-Za-z0-9_]+)\s+(?:[A-Za-z0-9_]+\s+)?=\s+/).each do |match|
                name = match[0]
                node.add_next_sibling("<div><a href=\"#{usages_url(name)}\">#{name} examples</a></div>")
              end
            end
          end
        end

        # Add examples link to every package constant
        css('h2#pkg-constants').each do |const_header_node|
          const_nodes = []
          cur_node = const_header_node.next_element
          while cur_node != nil
            if cur_node.name == 'h2'
              break
            end
            if cur_node.name == 'pre'
              const_nodes.push(cur_node)
            end
            cur_node = cur_node.next_element
          end
          const_nodes.each do |node|
            if node.name == "pre"
              node.text.scan(/^\s*(?:const\s+)?([A-Za-z0-9_]+)\s+(?:[A-Za-z0-9_]+\s+)?=\s+/).each do |match|
                name = match[0]
                node.add_next_sibling("<div><a href=\"#{usages_url(name)}\">#{name} examples</a></div>")
              end
            end
          end
        end

        doc
      end

      def usages_url(name)
        return "https://sourcegraph.com/github.com/golang/go/-/land/GoPackage/#{subpath}-/#{name}?utm_source=devdocs.io&utm_medium=web&utm_campaign=docs"
      end
    end
  end
end
