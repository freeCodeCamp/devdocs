module Docs
  class SanctuaryDef
    class CleanHtmlFilter < Filter
      def call
        # Make headers bigger by transforming them into a bigger variant
        css('h3').each { |node| node.name = 'h2' }
        css('h4').each { |node| node.name = 'h3' }

        doc
      end
    end
  end
end
