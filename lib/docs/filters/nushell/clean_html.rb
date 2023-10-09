module Docs

  class Nushell
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.theme-default-content > div:only-child', '.theme-default-content')
        css('footer').remove
        css('h1 a, h2 a').remove
        doc
      end
    end
  end

end
