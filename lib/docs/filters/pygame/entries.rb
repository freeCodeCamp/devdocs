module Docs
  class Pygame
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        return 'pygame'
      end

      def get_type
        at_css('h1').content
      end

      def include_default_entry?
        return false
      end

      def additional_entries
        return ['pygame'] if root_page?

        entries = []
        css('h1,h2,h3').each do |node|
          parentclass = node.parent['class']
          name = node['id']
          if not name
            name = node['data-name']
          elsif parentclass.include?('function') or parentclass.include?('method')
            name += '()'
          end
          name = name.sub('pygame.', '')
          entries << [name, node['id'], nil]
        end
        entries
      end
    end
  end
end
