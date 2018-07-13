module Docs
  class Dart
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        breadcrumbs = at_css('.breadcrumbs').css('li:not(.self-crumb) > a')
        breadcrumbs = breadcrumbs.length == 1 ? [] : breadcrumbs.slice(1..-1).map {|node| node.content}

        first_part = breadcrumbs.join(':')
        separator = first_part.empty? ? '' : ':'
        last_part = get_title

        first_part + separator + last_part
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
    end
  end
end
