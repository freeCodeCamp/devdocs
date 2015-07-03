module Docs
  class Vue
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        type = nil

        doc.children.each_with_object [] do |node, entries|
          if node.name == 'h1'
            type = node.content.strip
          elsif node.name == 'h3'
            name = node.content.strip
            entries << [name, node['id'], type]
          end
        end
      end
    end
  end
end
