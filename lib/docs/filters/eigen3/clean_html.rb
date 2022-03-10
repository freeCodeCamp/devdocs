module Docs
  class Eigen3
    class CleanHtmlFilter < Filter

      def call
        @doc = at_css('#doc-content')
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
