module Docs
  class Pony
    class CleanHtmlFilter < Filter
      def call
        css('.headerlink').remove
        doc
      end
    end
  end
end
