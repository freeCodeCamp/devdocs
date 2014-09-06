module Docs
  class Express
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        type = 'Application'

        doc.children.each_with_object [] do |node, entries|
          if node.name == 'h2'
            type = node.content
            entries << [type, node['id'], 'Application'] if type == 'Middleware'
            next
          elsif node.name == 'h3'
            next if type == 'Middleware'
            name = node.content.strip
            name.sub! %r{\(.+\)}, '()'

            entries << [name, node['id'], type]
          end
        end
      end
    end
  end
end
