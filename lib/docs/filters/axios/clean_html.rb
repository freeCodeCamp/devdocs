module Docs
  class Axios
    class CleanHtmlFilter < Filter
      def call
        css('.links').remove
        doc
      end
    end
  end
end
