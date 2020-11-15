module Docs
  class Fish
    class EntriesCustomFilter < Docs::EntriesFilter
      def get_name
        if slug == 'faq'
          'FAQ'
        else
          slug.capitalize
        end
      end

      def get_type
        if root_page? || slug == 'faq'
          'Manual'
        else
          name
        end
      end

      def additional_entries
        return [] if slug == 'faq'
        css('h2').map.with_index do |node, i|
          name = node.content.split(' - ').first.strip
          name.prepend "#{i + 1}. " unless slug == 'commands'
          [name, node['id'], get_type]
        end
      end
    end
  end
end
