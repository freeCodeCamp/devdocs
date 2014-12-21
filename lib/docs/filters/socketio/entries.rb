module Docs
  class Socketio
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        'Guides'
      end

      def additional_entries
        return [] unless slug.end_with?('api')

        css('h3').each_with_object([]) do |node, entries|
          name = node.content
          name.remove! %r{\(.*}
          name.remove! %r{\:.*}

          unless entries.any? { |entry| entry[0] == name }
            entries << [name, node['id'], self.name.remove(' API')]
          end
        end
      end
    end
  end
end
