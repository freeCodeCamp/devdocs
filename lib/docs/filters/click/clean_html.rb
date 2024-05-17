module Docs
  class Click
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          # Image renders quite badly in dark mode
          at_css('h1 + a.image-reference').remove
          # All superfluous
          css('#documentation, #api-reference, #miscellaneous-pages').remove
        end
        doc
      end
    end
  end
end
