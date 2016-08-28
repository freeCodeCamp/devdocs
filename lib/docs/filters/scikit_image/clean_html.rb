module Docs
  class ScikitImage
    class CleanHtmlFilter < Filter
      def call
        css('h2').remove
        css('h1 + table').remove
        doc
      end
    end
  end
end
