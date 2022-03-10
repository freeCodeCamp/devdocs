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
          when "Public Member Functions", "Static Public Member Functions"
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

          table.css('td.memItemRight,td.memTemplItemRight').map do |node|
            if node.content.include?('KLU')
              puts(node.content)
            end
            href = node.at_css("a")
            if href.nil?
              next
            end

            href = node.at_css("a").attr('href')

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

            content = node.content
            if doxygen_type == "Typedefs"
              content = content.sub(/\s*=.*$/, "")
            end
            if not (name.end_with?('module') || name.end_with?('typedefs')) \
              and not content.start_with?("Eigen::")
              content = name + "::" + content
            end

            entries << [content, href, type]
          end
        end
        entries
      end
    end
  end
end
