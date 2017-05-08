module Docs
  class Liquid
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        if not root_page?
          slug.split('/').first.capitalize
        end
      end

      def additional_entries
        entries = []

        if get_type == 'Tags'
          css('h2').each do |node|
            entries << [node.content, node['id']]
          end
        end

        entries
      end

    end
  end
end
