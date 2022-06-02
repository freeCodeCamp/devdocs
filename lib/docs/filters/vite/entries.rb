module Docs
  class Vite
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content
        name.sub! %r{\s*#\s*}, ''
        name
      end

      def get_type
        at_css('header nav .item.active').content.strip
      end

      def additional_entries
        css('h2, h3').each_with_object [] do |node, entries|
          type = node.content.strip
          type.sub! %r{\s*#\s*}, ''
          entries << ["#{name}: #{type}", node['id']]
        end
      end
    end
  end
end
