module Docs
  class Relay
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          at_css('h1').content = 'Relay Documentation'
        end

        doc
      end
    end
  end
end
