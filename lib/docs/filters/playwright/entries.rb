module Docs
  class Playwright
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').children.select(&:text?).map(&:content).join.strip
      end

      def type
        type = at_css('.menu__link--active').content
        return "#{type}: #{name}" if slug.starts_with?('api/')
        type
      end

      def additional_entries
        css('x-search').each_with_object [] do |node, entries|
          prev = node.previous_element
          prev = prev.previous_element until prev['id']
          entries << [node.text, prev['id']]
        end
      end
    end
  end
end
