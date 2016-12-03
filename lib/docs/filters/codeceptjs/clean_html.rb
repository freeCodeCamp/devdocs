module Docs
  class Codeceptjs
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
        doc.inner_html = ' '
      end

      def other
        @doc = doc.at_css('div.reference').xpath('//div[@role="main"]')
        doc
      end
    end
  end
end
