module Docs
  class Jasmine
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content.strip
      end

      def get_type
        name
      end

      def additional_entries
        css('h4[id]').each_with_object [] do |node, entries|
          name = node['id']
          entries << [name.sub(/\./, ''), name]
        end
      end
    end
  end
end
