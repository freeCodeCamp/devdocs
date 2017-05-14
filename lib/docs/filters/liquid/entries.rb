module Docs
  class Liquid
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        slug.split('/').first.capitalize
      end

      def additional_entries
        return [] unless type == 'Tags'

        css('h2').map do |node|
          [node.content, node['id']]
        end
      end
    end
  end
end
