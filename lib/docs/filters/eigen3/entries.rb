module Docs
  class Eigen3
    class EntriesFilter < Docs::EntriesFilter
      def get_type
        group = at_css('.title .ingroups')
        content = at_css('.contents').content
        title = get_title()
        downtitle = title.downcase
        name = get_name

        if slug.include?('unsupported')
          return 'Unsupported'
        elsif slug.start_with?('Topic') || downtitle.end_with?("topics")
            return 'Topics'
        elsif downtitle.end_with?("class template reference") || downtitle.end_with?("class reference")
          return 'Classes'
        elsif downtitle.end_with?("struct reference")
          return 'Structs'
        elsif downtitle.end_with?("typedefs")
          return 'Typedefs'
        elsif downtitle.end_with?("namespace reference")
            return 'Namespaces'
        elsif not group.nil? and group.content.include?('Reference') and (downtitle.end_with?("module") || downtitle.end_with?("modules"))
            return "Modules"
        elsif not group.nil?
          if group.children.length > 0
            return 'Chapter: ' + group.children[-1].content
          else
            return 'Chapter: ' + group.content
          end
        else
          return 'Eigen'
        end
      end

      def get_name
        title = get_title().gsub(/[<(].*/, '').gsub(/(Class|Class Template|Namespace|Struct) Reference/, '').strip
      end

      def get_title
        unless at_css('.title').nil?
          group = at_css('.title .ingroups')
          title = at_css('.title').content
          if not group.nil?
            title = title.delete_suffix(group.content)
          end
          return title.strip
        else
          return slug
        end
      end


      def additional_entries
        # return [] if slug.include?('unsupported')
        name = get_name()
        entries = []

        css('table.memberdecls').map do |table|
          doxygen_type = table.at_css("tr.heading").text.strip
          case doxygen_type
          when "Functions"
            type = "Functions"
          when "Public Member Functions", "Static Public Member Functions", "Public Types", "Additional Inherited Members"
            type = nil
          when "Classes"
            type = "Classes"
          when "Typedefs"
            type = "Typedefs"
          when "Variables"
            type = "Variables"
          else
            next
          end

          tmp_entries = []

          table.css('td.memItemRight,td.memTemplItemRight').map do |node_r|
            node_l = node_r.parent.at_css('memItemLeft')
            if (not node_l.nil? and node_l.text.strip == 'enum') || node_r.content.include?('{')
              node_r.css("a").each {|n| tmp_entries << [n.content, n.attr('href')]}
            else
              n = node_r.at_css("a")
              next if n.nil?
              tmp_entries << [node_r.content, n.attr('href')]
            end
          end

          tmp_entries.each do |args|
            (content, href) = args
            next if href.nil?
            if not href.include?("#") and (name == 'Eigen' || type == "Classes") then
              next
            end

            if slug.include?('unsupported')
              if not (href.include?('unsupported') || href.include?('#'))
                next
              elsif href.include?('#') and not href.include?('unsupported')
                href = 'unsupported/' + href
              end
            end

            if doxygen_type == "Typedefs"
              content = content.sub(/\s*=.*$/, "")
            end

            if not (name.end_with?('module') || name.end_with?('typedefs')) \
              and not content.start_with?("Eigen::")
              content = name + "::" + content
            end
            content.gsub! /^\s+/, ''
            content.gsub! /\s+,\s+/, ', '
            content.gsub! /\s\s+/, ' '
            entries << [content, href, type]
          end

        end
        entries
      end
    end
  end
end
