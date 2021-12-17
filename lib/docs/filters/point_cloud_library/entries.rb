module Docs
  class PointCloudLibrary
    class EntriesFilter < Docs::EntriesFilter
      def get_type
        if slug.start_with?("group")
          'Group'
        else
          'Others'
        end
      end

      def additional_entries
        return [] if root_page?

        css('table.memberdecls td.memItemRight').map do |node|
          # Get the type of the entry from Doxygen table heading
          type = node.parent.parent.css("tr.heading").text.strip
          if type == 'Additional Inherited Members' then
            return []
          end

          # Retrieve HREF link
          first_link = node.css("a").first
          if first_link.nil? then
            return []
          end
          href = first_link['href']
          if href.index("#").nil? then
            # If it doesn't have #, it means it's linking to other page.
            # So append # at the end to make it work
            href += "#"
          end

          [node.content, href, type]
        end
      end

      def include_default_entry?
        !at_css('.obsolete')
      end
    end
  end
end
