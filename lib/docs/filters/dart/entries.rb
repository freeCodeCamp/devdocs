module Docs
  class Dart
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        title = at_css('h1.title')
        if title # v1
          name = title.element_children.last.content.strip
          kind = title.at_css('.kind').content
        else # v2
          title = at_css('.main-content > h1')
          name = title.content[/(.*)( )/, 1].split(' top-level')[0]
          kind = title.content[/(.*)( )(.+)/, 3]
        end

        breadcrumbs = at_css('.breadcrumbs').css('li:not(.self-crumb) > a')
        first_part = ''

        if breadcrumbs.length == 2 && !kind.include?('class')
          first_part = breadcrumbs[1].content
        elsif breadcrumbs.length == 3
          first_part = breadcrumbs[2].content
        end

        separator = ''

        unless first_part.empty?
          if kind.include?('class')
            separator = ':'
          else
            separator = '.'
          end
        end

        "#{first_part}#{separator}#{name}"
      end

      def get_type
        at_css('.breadcrumbs > li:nth-child(2)').content.split(' ')[0]
      end
    end
  end
end
