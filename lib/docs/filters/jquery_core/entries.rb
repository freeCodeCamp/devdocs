module Docs
  class JqueryCore
    class EntriesFilter < Docs::EntriesFilter
      # Ordered by precedence
      TYPES = ['Ajax', 'Selectors', 'Callbacks Object', 'Deferred Object',
        'Data', 'Utilities', 'Events', 'Effects', 'Offset', 'Dimensions',
        'Traversing', 'Manipulation']

      def get_name
        name = at_css('h1').content.strip
        name.gsub!(/ [A-Z]/) { |str| str.downcase! }
        name
      end

      def get_type
        return 'Ajax' if slug == 'Ajax_Events'
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
