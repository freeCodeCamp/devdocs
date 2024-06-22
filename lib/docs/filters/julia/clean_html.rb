module Docs
  class Julia
    class CleanHtmlFilter < Filter
      def call
        css('> header', '> footer').remove

        # Julia 1.4+ uses different HTML
        at_css('h1').content = at_css('h1').content

        if at_css('#documenter-page')
          @doc.children = at_css('#documenter-page').children
        end
        # End 1.4+ specific cleaning

        css('.docstring', 'div:not([class])').each do |node|
          node.before(node.children).remove
        end

        css('.docstring-header', 'header').each do |node|
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
          node['data-language'] = 'julia'
        end

        doc
      end
    end
  end
end
