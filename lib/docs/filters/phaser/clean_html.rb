module Docs
  class Phaser
    class CleanHtmlFilter < Filter
      def call
        title = at_css('h1')

        if root_page?
          @doc = at_css('#docs-index')

          # Remove first paragraph (old doc details)
          at_css('table').remove

          title.content = 'Phaser'
        else
          @doc = at_css('#docs')

          # Remove useless markup
          css('section > article').each do |node|
            node.parent.replace(node.children)
          end

          css('dt > h4').each do |node|
            dt = node.parent
            dd = dt.next_element
            dt.before(node).remove
            dd.before(dd.children).remove
          end

          css('> div', '> section').each do |node|
            node.before(node.children).remove
          end

          css('h3.subsection-title').each do |node|
            node.name = 'h2'
          end

          css('h4.name').each do |node|
            node.name = 'h3'
          end
        end

        doc.child.before(title)

        # Clean code blocks
        css('pre > code').each do |node|
          node.before(node.children).remove
        end

        css('pre').each do |node|
          node['data-language'] = 'javascript'
        end

        doc
      end
    end
  end
end
