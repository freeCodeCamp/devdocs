module Docs
  class Fish
    class EntriesSphinxFilter < Docs::EntriesFilter
      def get_name
        if slug == 'faq'
          'FAQ'
        elsif slug.starts_with?('cmds/')
          slug.split('/').last
        else
          slug.capitalize
        end
      end

      def get_type
        if root_page? || slug == 'faq'
          'Manual'
        elsif slug.starts_with?('cmds')
          'Commands'
        elsif slug == 'tutorial'
          'Tutorial'
        else
          nil # Remaining pages are indexes we don't need
        end
      end

      def additional_entries
        if root_page? || slug == 'tutorial'
          css('h2').map.with_index do |node, i|
            name = node.content.split(' - ').first.strip
            name.prepend "#{i + 1}. "
            [name, node['id'], get_type]
          end
        else
          []
        end
      end
    end
  end
end
