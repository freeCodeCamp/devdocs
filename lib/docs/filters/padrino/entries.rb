module Docs
  class Padrino
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        node = at_css('h1')
        result = node.content.strip
        result << ' event' if type == 'Events'
        result << '()' if node['class'].try(:include?, 'function')
        result
      end

      def get_type
        return 'Ruby'
      end
    end
  end
end
