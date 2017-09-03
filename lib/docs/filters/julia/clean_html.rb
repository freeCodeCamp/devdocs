module Docs
  class Julia
    class CleanHtmlFilter < Filter
      def call
        css('> header', '> footer').remove

        css('.docstring', 'div:not([class])').each do |node|
          node.before(node.children).remove
        end

        css('.docstring-header').each do |node|
          node.name = 'h3'
          node.children.each { |child| child.remove if child.text? }
          node.remove_attribute('class')
        end

        css('a.docstring-binding[id]', 'a.nav-anchor').each do |node|
          node.parent['id'] = node['id']
          node.before(node.children).remove
        end

        css('pre').each do |node|
          node.content = node.content
        end

        doc
      end
    end
  end
end
