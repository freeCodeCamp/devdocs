module Docs
  class JqueryUi
    class EntriesFilter < Docs::EntriesFilter
      # Ordered by precedence
      TYPES = ['Widgets', 'Selectors', 'Effects', 'Interactions', 'Methods']

      def get_name
        name = at_css('h1').content.strip
        name.remove! ' Widget' unless name.start_with?('Category')
        name.gsub!(/ [A-Z]/) { |str| str.downcase! }
        name
      end

      def get_type
        categories = css 'span.category'
        types = categories.map { |node| node.at_css('a').content.strip }
        types.map! { |type| TYPES.index(type) }
        types.compact!
        types.sort!
        types.empty? ? 'Miscellaneous' : TYPES[types.first]
      end
    end
  end
end
