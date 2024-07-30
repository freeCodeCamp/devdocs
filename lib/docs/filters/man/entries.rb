module Docs
  class Man
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        at_css('h1').content.sub(' — Linux manual page', '')
      end

      def get_type
        'Linux manual page'
      end

      def entries
        return super unless slug == 'dir_by_project'
        type0 = nil
        return css('*').each_with_object [] do |node, entries|
          if node.name == 'h2'
            type0 = node.content
          elsif node.name == 'a' and node['href'] and node['href'].start_with?('man') and type0
            name = node.content + node.next_sibling.content
            path = node['href']
            entries << Entry.new(name, path, type0)
          end
        end
      end

    end
  end
end
