module Docs
  class Codeception
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
        doc.inner_html = ' '
      end

      def other
        @doc = doc.at_css('div.page, div.content')
        css('.btn-group').remove
        doc
      end
    end
  end
end
