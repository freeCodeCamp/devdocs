module Docs
  class Phalcon
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.body')

        # Remove unnecessary things
        css('').remove

        # Add id for constants and methods
        css('#constants strong', '#methods strong').each do |node|
          node.parent['id'] = node.content.strip
        end

        doc
      end
    end
  end
end
