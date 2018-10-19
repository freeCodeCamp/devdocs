module Docs
  class Handlebars
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        subpath[0..-6].titleize
      end

      def get_type
        name
      end

      def additional_entries
        css('h2, h3').to_a.map do |node|
          [node.content.strip, node['id'], root_page? ? 'Manual' : nil]
        end
      end
    end
  end
end
