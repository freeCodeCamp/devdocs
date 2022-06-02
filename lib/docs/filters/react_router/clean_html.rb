module Docs
  class ReactRouter
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.md-prose')
        css('pre').each do |node|
          node.content = node.css('.codeblock-line').map(&:content).join("")
          node['data-language'] = 'javascript'
        end
        doc
      end
    end
  end
end
