module Docs
  class Node
    class CleanHtmlFilter < Filter
      def call
        # Remove "#" links
        css('.mark').each do |node|
          node.parent.parent['id'] = node['id']
          node.parent.remove
        end

        doc
      end
    end
  end
end
