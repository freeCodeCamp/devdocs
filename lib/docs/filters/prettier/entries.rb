module Docs
  class Prettier
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').children.select(&:text?).map(&:content).join.strip
      end

      def type
        link = at_css('.menu__link--active')
        section = link.ancestors('.theme-doc-sidebar-item-category-level-1').first
        type = section.at_css('.menu__link--sublist').content.strip
        return name if type == 'Configuring Prettier'
        return name if type == 'Usage'
        type
      end

      def additional_entries
        entries = []
        css('h2').each do |node|
          entries << [node.text, node['id']]
        end
        entries
      end
    end
  end
end
