module Docs
  class Eigen3
    class CleanHtmlFilter < Filter

      def call
        # TODO doc.inner_html = parse
        # inner_html = String.new(doc.inner_html).gsub(/<div class="line">(.*?)<\/div>/m, "\\1\n").gsub(/<div class="fragment">(.*?)<\/div>/m, '<pre class="fragment">\1</pre>')
        # doc.inner_html = inner_html
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
