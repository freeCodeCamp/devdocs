module Docs
  class Pygame
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content.remove('pygame.')
      end

      def get_type
        at_css('h1').content
      end

      def additional_entries
        return [] if root_page?

        css('h1, h2, h3').each_with_object [] do |node, entries|
          name = node['id'] || node['data-name']

          if node.parent['class'].include?('function') or node.parent['class'].include?('method')
            name << '()'
          end

          name.remove!('pygame.')

          entries << [name, node['id']] unless name == self.name
        end
      end
    end
  end
end
