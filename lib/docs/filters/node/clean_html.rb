module Docs
  class Node
    class CleanHtmlFilter < Filter
      def call
        css('hr').remove

        # Remove "#" links
        css('.mark').each do |node|
          node.parent.parent['id'] = node['id']
          node.parent.remove
        end

        css('pre[class*="api_stability"]').each do |node|
          node.name = 'div'
        end

        css('pre').each do |node|
          if lang = node.at_css('code')['class']
            node['data-language'] = lang.remove('lang-')
          end

          node.content = node.content
        end

        doc
      end
    end
  end
end
