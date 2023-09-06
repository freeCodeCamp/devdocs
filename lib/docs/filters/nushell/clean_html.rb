module Docs

  class Nushell
    class CleanHtmlFilter < Filter
      def call
        # css('header').remove
        # css('aside').remove
        css('footer').remove
        css('h1 a, h2 a').remove
        doc
      end
    end
  end

end
