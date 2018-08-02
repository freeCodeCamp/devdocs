module Docs
  class Puppeteer
    class CleanHtmlFilter < Filter
      def call
        # None of the elements to remove have classes, so the order of the remove calls is trivial

        # Remove links to previous versions of the reference
        at_css('h5').remove

        # Remove table of contents
        at_css('h5').remove
        at_css('ul').remove

        # Make headers bigger by transforming them into a bigger variant
        css('h3').each {|node| node.name = 'h2'}
        css('h4').each {|node| node.name = 'h3'}

        css('pre').each do |node|
          # Remove nested tags
          node.content = node.content

          # Add syntax highlighting
          node['data-language'] = 'js'
        end

        doc
      end
    end
  end
end
