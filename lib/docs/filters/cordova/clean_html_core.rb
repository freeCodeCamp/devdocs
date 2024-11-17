module Docs
  class Cordova
    class CleanHtmlCoreFilter < Filter
      def call
        css('script', 'style', 'link').remove
        xpath('descendant::comment()').remove
        doc
      end
    end
  end
end
