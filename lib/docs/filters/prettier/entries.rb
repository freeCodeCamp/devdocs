module Docs
  class Prettier
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').children.select(&:text?).map(&:content).join.strip
      end

      def type
        link = at_css('.navListItemActive')
        section = link.ancestors('.navGroup').first
        type = section.at_css('h3').content.strip
        return name if type == 'Configuring Prettier'
        return name if type == 'Usage'
        type
      end

      def additional_entries
        entries = []
        css('.mainContainer h2').each do |node|
          id = node.at_css('.anchor')['id']
          entries << [node.text, id]
        end
        entries
      end
    end
  end
end
