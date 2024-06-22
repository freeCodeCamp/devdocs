module Docs
  class Pygame
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('.title').content.remove('pygame.').strip
      end

      def get_type
        at_css('.title').content.strip
      end

      def additional_entries
        css('dl.definition > dt.title').each_with_object [] do |node, entries|
          name = node['id'] || node.parent.parent['id']
          name.remove! 'pygame.'
          id = node['id']
          entries << [name, id] unless name == self.name
        end
      end
    end
  end
end
