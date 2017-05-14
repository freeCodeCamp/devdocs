module Docs
  class Jasmine
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.docs')

        at_css('h1').content = 'Jasmine' if root_page?

        css('header', 'article', 'section:not([class])', 'div.description').each do |node|
          node.before(node.children).remove
        end

        css('h3.subsection-title').each do |node|
          node.name = 'h2'
        end

        css('h4.name').each do |node|
          node.name = 'h3'
        end

        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = 'javascript'
        end

        doc
      end
    end
  end
end
