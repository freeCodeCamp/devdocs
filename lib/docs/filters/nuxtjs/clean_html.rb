module Docs
  class Nuxtjs
    class CleanHtmlFilter < Filter
      def call

        # Remove option selectors (e.g. Yarn / NPX / NPM) since we show each section
        css('.d-code-group-header-bg').remove

        # Remove a in headers
        css('h2 > a', 'h3 > a').each do |node|
          node.parent.content = node.content
          node.remove
        end

        doc
      end
    end
  end
end
