module Docs
  class Fortran
    class CleanHtmlFilter < Filter
      def call
        css('h2', 'h3', 'h4').each do |node|
          node.name = 'h1'
        end

        # Move page anchor to page title
        at_css('h1')['id'] = at_css('.node > a')['name']

        css('.node', 'br').remove

        doc
      end
    end
  end
end
