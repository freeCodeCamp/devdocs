module Docs
  class D3
    class EntriesV3Filter < Docs::EntriesFilter
      def get_name
        File.basename(slug, '.md').gsub('-', ' ')
      end

      def get_type
        at_css('h6[id]') ? name : 'D3'
      end

      def additional_entries
        css('h6[id]').each_with_object [] do |node, entries|
          name = node.content.strip
          name.sub! %r{\(.*\z}, '()'
          name.sub! %r{\A(svg:\w+)\s+.+}, '\1'
          entries << [name, node['id']] unless name == entries.last.try(:first)
        end
      end
    end
  end
end
