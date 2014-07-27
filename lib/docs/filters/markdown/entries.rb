module Docs
  class Markdown
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        type = nil

        doc.children.each_with_object [] do |node, entries|
          if node.name == 'h2'
            type = node.content.strip
          elsif node.name == 'h3'
            next if type == 'Overview'
            name = node.content.strip
            entries << [name, node['id'], type]
          end
        end
      end
    end
  end
end
