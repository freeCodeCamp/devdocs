module Docs
  class Express
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        type = 'Application'

        doc.children.each_with_object [] do |node, entries|
          if node.name == 'h2'
            type = node.content
            next
          elsif node.name == 'h3'
            name = node.content.strip
            name.sub! %r{\(.+\)}, '()'

            entries << [name, node['id'], type]
          end
        end
      end
    end
  end
end
