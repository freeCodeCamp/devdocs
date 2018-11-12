module Docs
  class Jest
    class CleanHtmlFilter < Filter
      def call
        at_css('h1').content = 'Jest' if root_page?

        doc
      end
    end
  end
end
