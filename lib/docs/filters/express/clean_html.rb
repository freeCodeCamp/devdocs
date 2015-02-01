module Docs
  class Express
    class CleanHtmlFilter < Filter
      def call
        css('section').each do |node|
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
        css('pre').each do |node|
          node.content = node.content
        end

        doc
      end
    end
  end
end
