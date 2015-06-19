module Docs
  class Webpack
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        entry_link.content.strip.titleize
      end

      def get_type
        link_li = entry_link.parent
        type_links_list = link_li.parent
        current_type = type_links_list.parent

        # current type is a 
        # <li>
        #   TYPE
        #   <li> <ul> .. links .. </ul> </li>
        # </li>
        #
        # Grab the first children (which is the text nodes whose contains the type)
        current_type.children.first.content.strip.titleize
      end

      
      def additional_entries
        return [] unless root_page?

        css('.sidebar a').each_with_object [] do |link, entries|
          name = link.content.strip
          entries << [name, link['href']]
        end
      end

      private

      def entry_link
        at_css("a[href='#{self.path}']")
      end
    end
  end
end

