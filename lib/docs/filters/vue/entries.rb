module Docs
  class Vue
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content.presence || 'API'
      end

      def get_type
        if slug.start_with?('guide')
          'Guide'
        else
          'API'
        end
      end

      def additional_entries
        return [] if slug.start_with?('guide')
        type = nil

        css('h2, h3').each_with_object [] do |node, entries|
          if node.name == 'h2'
            type = node.content.strip
          else
            name = node.content.strip
            name.sub! %r{\(.*\)}, '()'
            entries << [name, node['id'], "API: #{type}"]
          end
        end
      end
    end
  end
end
