module Docs
  class Express
    class CleanHtmlFilter < Filter
      def call
        css('section', 'div.highlighter-rouge').each do |node|
          node.before(node.children).remove
        end

        doc.child.remove while doc.child.name != 'h1'

        at_css('h1').remove if root_page?

        # Put id attributes on headings
        css('h2 + a[name]').each do |node|
          node.previous_element['id'] = node['name']
          node.remove
        end

        css('table[border]').each do |node|
          node.remove_attribute 'border'
        end

        # Remove code highlighting
        css('figure.highlight').each do |node|
          node['data-language'] = node.at_css('code[data-lang]')['data-lang']
          node.content = node.content
          node.name = 'pre'
        end

        css('pre > code').each do |node|
          node.parent['data-language'] = node['class'][/language-(\w+)/, 1] if node['class']
          node.parent.content = node.parent.content
        end

        doc
      end
    end
  end
end
