module Docs
  class Chefclient
    class CleanHtmlFilter < Filter
      def call
        css('h1 a, h2 a, h3 a').remove
        doc = at_css('div.body[role="main"]')
        doc
      end
    end
  end
end
