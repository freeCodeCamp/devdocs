module Docs
  class Eigen3
    class CleanHtmlFilter < Filter

      def call
        @doc = at_css('#doc-content')

        css("div.fragment").each do |node|
          node.css("div.line").each do |node|
            node.replace(node.inner_html + "\n")
          end
          node.replace("<pre data-language=\"cpp\" class=\"fragment\">" + node.inner_html + "</pre>")
        end

        css('#MSearchSelectWindow').remove
        css('#MSearchResultsWindow').remove
        css('.directory .levels').remove
        css('.header .summary').remove
        css('.ttc').remove
        css('.top').remove
        css('.dynheader.closed').remove
        css('.permalink').remove
        doc
      end
    end
  end
end
