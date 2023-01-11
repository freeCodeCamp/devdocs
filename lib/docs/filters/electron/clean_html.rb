module Docs
  class Electron
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css(".markdown")

        css(".theme-doc-toc-desktop").remove

        css(".theme-doc-toc-mobile").remove

        css(".clean-btn").remove

        css("footer").remove

        css('pre').each do |node|
          node.content = node.css('.token-line').map(&:content).join("\n")
          node['data-language'] = 'javascript'
        end

        doc
      end
    end
  end
end
