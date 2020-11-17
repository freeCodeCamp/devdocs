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

        doc

      end
    end
  end
end
