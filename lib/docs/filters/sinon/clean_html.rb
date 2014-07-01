module Docs
  class Sinon
    class CleanHtmlFilter < Filter
      def call
        css('> p:first-child', 'a.api', 'ul.nav').remove

        css('.section', 'h2 code', 'h3 code').each do |node|
          node.before(node.children).remove
        end

        # Remove code highlighting
        css('pre').each do |node|
          node.content = node.content
        end

        doc
      end
    end
  end
end
