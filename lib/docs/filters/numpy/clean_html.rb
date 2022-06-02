module Docs
  class Numpy
    class CleanHtmlFilter < Filter
      def call
        css('.sphinx-bs.container.pb-4.docutils').remove if root_page?
        at_css('main > div > section', '#spc-section-body, main > div')
      end
    end
  end
end
