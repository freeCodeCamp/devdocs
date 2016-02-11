module Docs
  class Haxe
    class CleanHtmlFilter < Filter
      def call
        css('.viewsource').remove
        doc
      end
    end
  end
end
