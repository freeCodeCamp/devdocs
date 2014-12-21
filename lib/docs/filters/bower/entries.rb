module Docs
  class Bower
    class EntriesFilter < Docs::EntriesFilter
      ENTRIES_TYPE_BY_SLUG = {
        'api'    => 'Commands',
        'config' => '.bowerrc'
      }

      def get_name
        at_css('h1').content
      end

      def get_type
        'Guides'
      end

      def additional_entries
        return [] unless type = ENTRIES_TYPE_BY_SLUG[slug]

        css('#bowerrc-specification + ul a', '#commands + p + ul a').map do |node|
          [node.content, node['href'].remove('#'), type]
        end
      end
    end
  end
end
