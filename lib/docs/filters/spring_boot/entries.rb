module Docs
  class SpringBoot
    class EntriesFilter < Docs::EntriesFilter
    
      def get_type
        slug.gsub('-', ' ').capitalize
      end

      def additional_entries
        css('td a[href], li a[href]').each_with_object [] do |node, entries|
          next if root_page?
          next if node['href'].start_with?('http')
          name = node.content.strip
          id = node['href'].remove('#')
          next if id.blank?
          entries << [name, id, get_type]
        end
      end
    end
  end
end
