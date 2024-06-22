module Docs
  class Babel
    class CleanHtmlFilter < Filter
      def call

        @doc = at_css('.theme-doc-markdown')

        css('.fixedHeaderContainer').remove

        css('.toc').remove

        css('.toc-headings').remove

        css('.postHeader > a').remove

        css('.nav-footer').remove

        css('.docs-prevnext').remove

        css('pre').each do |node|
          node.content = node.css('.token-line').map(&:content).join("\n")
          node['data-language'] = node['class'][/language-(\w+)/, 1]
        end

        css('.codeBlockTitle_x_ju').remove

        css('*').remove_attr('class')

        css('*').remove_attr('style')

        doc

      end
    end
  end
end
