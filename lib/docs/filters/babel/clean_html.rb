module Docs
  class Babel
    class CleanHtmlFilter < Filter
      def call

        css('.fixedHeaderContainer').remove

        css('.toc').remove

        css('.toc-headings').remove

        css('.postHeader > a').remove

        css('.nav-footer').remove

        css('.docs-prevnext').remove

        css('pre > code.hljs').each do |node|
          node.parent['data-language'] = node['class'][/language-(\w+)/, 1]
        end

        css('pre').each do |node|
          node.content = node.content
        end

        doc

      end
    end
  end
end
