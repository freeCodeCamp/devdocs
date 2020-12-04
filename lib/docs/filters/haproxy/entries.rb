module Docs
  class Haproxy
    class EntriesFilter < Docs::EntriesFilter
      TYPE_BY_SLUG = {
        'intro' => 'Starter Guide',
        'configuration' => 'Configuration Manual',
        'management' => 'Management Guide',
      }

      REPLACE_TYPE = {
        'Management: 2) Typed output format' => 'Statistics and monitoring'
      }

      def get_name
        'HAProxy'
      end

      def get_type
        'HAProxy'
      end

      def additional_entries
        entries = []

        css('h2[id]', 'h3[id]').each do |node|
          entries << [node.content.strip, node['id'], TYPE_BY_SLUG[slug]]
        end

        type = 'x'
        @doc.children.each do |node|
          if node.name == 'h2' && node['id'] =~ /chapter/
            type = slug.titleize + ': ' + node.content.split('.').last.strip
          elsif node.name == 'div'
            node.css('.keyword').each do |n|
              name = n.at_css('b').content
              id = n['id']
              entries << [name, URI.escape(id), REPLACE_TYPE[type] || type]
            end
          end
        end
        entries
      end

      def include_default_entry?
        false
      end
    end
  end
end
