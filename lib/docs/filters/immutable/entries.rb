module Docs
  class Immutable
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        return 'Util' if slug.match?(/^([a-z]|Range|Repeat)/)
        at_css('h1').content
      end

      def additional_entries
        return [] if root_page?
        entries = []
        css('h2, h3, h4').each do |node|
          name = node.content
          id = node.parent['id']
          next unless id
          entries << ["#{type}.#{name}", id, type]
        end
        entries
      end
    end
  end
end
