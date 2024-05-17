module Docs
  class Click
    class PreCleanHtmlFilter < Filter
      def call
        # Remove ¶ character from headers
        css('.headerlink').remove
        doc
      end
    end
  end
end
