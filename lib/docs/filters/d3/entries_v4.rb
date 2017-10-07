module Docs
  class D3
    class EntriesV4Filter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content
        name.remove! 'd3-'
        name
      end

      def get_type
        return 'D3' unless at_css('h6[id]')
        type = name.titleize
        type.sub! 'Hsv', 'HSV'
        type.sub! 'Dsv', 'DSV'
        type
      end

      def additional_entries
        css('h6[id]').each_with_object [] do |node, entries|
          name = node.content.strip
          name.remove! 'Source'
          name.remove! '<>'
          name.remove! %r{\s\-.*}
          name.remove! %r{\s*\[.*\]}
          name.gsub! %r{\(.+?\)\)?}, '()'
          name.sub! %r{\A(svg:\w+)\s+.+}, '\1'
          name.split(/\s+/).each do |n|
            next if n.blank?
            entries << [n, node['id']] unless n == entries.last.try(:first)
          end
        end
      end
    end
  end
end
