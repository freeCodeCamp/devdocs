module Docs
  class Electron
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css(".markdown")

        css("header").before(at_css("h1"))

        css(".theme-doc-toc-desktop").remove

        css(".theme-doc-toc-mobile").remove

        css(".clean-btn").remove

        css("footer").remove

        doc
      end
    end
  end
end
