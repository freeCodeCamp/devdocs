module Docs
  class Phalcon
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.body')

        # Remove unnecessary things
        css('.headerlink', '#what-is-phalcon', '#other-formats', '#welcome h1', '#welcome p', '#table-of-contents h2').remove

        doc
      end
    end
  end
end
