module Docs
  class Puppeteer
    class CleanHtmlFilter < Filter
      def call
        at_css('h1').content = 'Puppeteer Documentation'

        # None of the elements to remove have classes, so the order of the remove calls is trivial

        # Remove links to previous versions of the reference
        at_css('h1 + ul').remove

        # Remove table of contents
        at_css('h1 + h5').remove
        at_css('h1 + ul').remove

        # Make headers bigger by transforming them into a bigger variant
        css('h3').each { |node| node.name = 'h2' }
        css('h4').each { |node| node.name = 'h3' }

        doc
      end
    end
  end
end
