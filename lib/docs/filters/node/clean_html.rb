module Docs
  class Node
    class CleanHtmlFilter < Filter
      def call
        # Remove "#" links
        css('.mark').each do |node|
          node.parent.parent['id'] = node['id']
          node.parent.remove
        end

        css('pre[class*="api_stability"]').each do |node|
          node.name = 'div'
        end

        css('pre').each do |node|
          node.content = node.content
        end

        doc
      end
    end
  end
end
