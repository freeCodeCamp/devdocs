module Docs
  class Jq
    class CleanHtmlFilter < Filter
      def call
        at_css('div#manualcontent')
      end
    end
  end
end
