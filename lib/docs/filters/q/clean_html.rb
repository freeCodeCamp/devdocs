module Docs
  class Q
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.markdown-body')

        css('h3 > a, h4 > a').each do |node|
          node.parent['id'] = node['href'].remove('#')
          node.remove
        end

        doc
      end
    end
  end
end
