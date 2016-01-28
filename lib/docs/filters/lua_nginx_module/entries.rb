module Docs
  class LuaNginxModule
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        type = nil 

        doc.children.each_with_object [] do |node, entries|
          if node.name == 'h1'
            type = node.content.strip
          elsif node.name == 'h2'
            entries << [ node.content, node["id"], type ]
          end
        end
      end
    end
  end
end
