module Docs
  class Chai
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        subpath.start_with?('/guide') ? 'Guides' : name
      end

      def additional_entries
        css('.antiscroll-inner a').each_with_object [] do |node, entries|
          id = node['href'].remove('#')
          node.content.strip.split(' / ').uniq { |name| name.downcase }.each do |name|
            entries << [name, id, self.name]
          end
        end
      end
    end
  end
end
