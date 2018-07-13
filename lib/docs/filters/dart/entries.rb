module Docs
  class Dart
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        title = get_title
        kind = get_kind

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

        first_part + separator + title
      end

      def get_type
        at_css('.breadcrumbs > li:nth-child(2)').content.split(' ')[0]
      end

      def get_title
        title = at_css('h1.title')

        if not title.nil?
          # v1
          title.children.last.content.strip
        else
          # v2
          at_css('.main-content > h1').content[/(.*)( )/, 1].split(' top-level')[0]
        end
      end

      def get_kind
        title = at_css('h1.title')

        if not title.nil?
          # v1
          title.at_css('.kind').content
        else
          # v2
          at_css('.main-content > h1').content[/(.*)( )(.+)/, 3]
        end
      end
    end
  end
end
