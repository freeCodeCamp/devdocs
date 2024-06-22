module Docs
  class Fluture
    class CleanHtmlFilter < Filter
      def call
        # Replace header image with text
        at_css('h1').content = 'Fluture'

        # Remove the build line
        css('h1 ~ p:first-of-type').remove

        # Remove the fantasy land image link
        css('p a').remove

        # Make headers bigger by transforming them into a bigger variant
        css('h3').each { |node| node.name = 'h2' }
        css('h4').each { |node| node.name = 'h3' }

        doc
      end
    end
  end
end
