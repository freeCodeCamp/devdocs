module Docs
  class Phalcon
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.body')

        # Remove unnecessary things
        css('.headerlink', '#what-is-phalcon', '#other-formats', '#welcome h1', '#welcome p', '#table-of-contents h2').remove

        # Add id for constants and methods
        css('#constants strong', '#methods strong').each do |node|
          node.parent['id'] = node.content.strip
        end

        doc
      end
    end
  end
end
