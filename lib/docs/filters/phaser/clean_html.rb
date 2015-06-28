module Docs
  class Phaser
    class CleanHtmlFilter < Filter
      def call

        title = at_css('h1')

        if root_page?
          doc.children = at_css('#docs-index')

          # Remove first paragraph (old doc details)
          doc.at_css('p').remove()
        else
          doc.children = at_css('#docs')

          # Remove "Jump to" block
          doc.at_css('table').remove()
        end

        doc.child.before title

        # Clean code blocks
        css('pre > code').each do |node|
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
