module Docs
  class Eigen3
    class EntriesFilter < Docs::EntriesFilter
      def get_type
        group = at_css('.title .ingroups')
        content = at_css('.contents').content
        title = get_title()
        downtitle = title.downcase
        name = get_name
        if content.include?('TODO: write this dox page!') ||
            content.blank? || content.empty?
          return nil
        end
        if slug.include?('unsupported')
          return 'Unsupported'
        elsif title.end_with?('module')
          return name
        elsif not group.nil? and not group.children[-1].nil? and group.children[-1].content != 'Reference'
          if group.children[-1].content.end_with?('module') || group.content.include?('Reference')
            return group.children[-1].content
          else
            return 'Chapter: ' + group.children[-1].content
          end
        elsif slug.start_with?('Topic') || downtitle.end_with?("topics")
          return 'Topics'
        elsif downtitle.end_with?("class template reference") || downtitle.end_with?("class reference") || downtitle.end_with?("struct reference")
          return 'Classes'
        elsif downtitle.end_with?("typedefs")
          return 'Typedefs'
        elsif downtitle.end_with?("namespace reference")
          return 'Namespaces'
        elsif name.match(/^Eigen::.*::/)
          return name.gsub(/^Eigen::/, '').gsub(/::.*/, '')
        elsif not group.nil? and not group.children[0].nil?
          return 'Chapter: ' + group.children[0].content
        # elsif slug.downcase.include?('tutorial')
        #   return nil
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
            type = name == 'Eigen' ? "Functions" : nil
          when "Public Member Functions", "Static Public Member Functions"
            type = nil
          when "Classes", "Typedefs"
            type = "Classes"
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
            if href.index("#").nil? then
              href += "#"
            end
            if slug.include?('unsupported') and not href.include?('unsupported')
              next
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
