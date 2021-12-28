module Docs
  class PointCloudLibrary
    class EntriesFilter < Docs::EntriesFilter
      def get_type
        if slug.include?("group__") then
          tmp = slug.dup
          tmp.sub! "group__", ""
          tmp.sub! "__", " "
          tmp
        else
          "‎"
        end
      end

      def get_name
        type = get_type()
        if type == "‎"
          slug
        else
          "Module " + type
        end
      end

      def additional_entries
        # Only add additional_entries from PointCloudLibrary modules (group__*.html)
        return [] if not slug.include?("group")
        entries = []

        css('table.memberdecls td.memItemRight').map do |node|
          href = node.at_css("a").attr('href')
          if href.index("#").nil? then
            href += "#"
          end

          # Skip page that's not crawled
          # TODO: Sync this with options[:skip_patterns] in point_cloud_library.rb
          if href.include?("namespace") || href.include?("structsvm") || href.include?("classopenni") then
            next
          end

          # Only add function and classes documentation
          doxygen_type = node.parent.parent.at_css("tr.heading").text.strip
          if not(doxygen_type == "Functions" || doxygen_type == "Classes") then
            next
          end

          entries << [node.content, href]
        end
        entries
      end
    end
  end
end
