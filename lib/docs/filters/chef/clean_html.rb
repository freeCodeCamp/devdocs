module Docs
  class Chef
    class CleanHtmlFilter < Filter
      def call
        css('h1 a', 'h2 a', 'h3 a','div.footer').remove
        doc
      end
    end
  end
end
