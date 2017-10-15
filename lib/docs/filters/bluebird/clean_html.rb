module Docs
  class Bluebird
    class CleanHtmlFilter < Filter
      def call
        css('.post-content > p:first').remove
        css('pre').attr('data-language', 'javascript')
        doc
      end
    end
  end
end
