module Docs
  class ReactNative
    class EntriesFilter < Docs::EntriesFilter
      REPLACE_TYPES = {
        'The Basics' => 'Getting Started',
        'apis' => 'APIs',
        'components' => 'Components'
      }

      def get_name
        at_css('h1').children.select(&:text?).map(&:content).join.strip
      end

      def get_type
        link = at_css('.navListItemActive')
        return 'Miscellaneous' unless link
        section = link.ancestors('.navGroup').first
        type = section.at_css('h3').content.strip
        type = REPLACE_TYPES[type] || type
        type += ": #{name}" if type == 'Components'
        type
      end

      def additional_entries
        css('.mainContainer h3').each_with_object [] do |node, entries|
          subname = node.text
          next if subname.blank? || node.css('code').empty?
          sep = subname.include?('()') ? '.' : '#'
          subname.prepend(name + sep)
          id = node.at_css('.anchor')['id']
          entries << [subname, id]
        end
      end
    end
  end
end
