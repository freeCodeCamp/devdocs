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
        css('.groupheader').remove
        css('.header').remove
        css('#details').remove
        css('*').each do |node|
          node.remove_attribute('class')
        end
        doc
      end
    end
  end
end
