module Docs
  class Mongoose
    class CleanHtmlFilter < Filter
      def call
        css('hr', '.showcode', '.sourcecode').remove

        if slug == 'api'
          at_css('.controls').after('<h1>Mongoose API</h1>')

          css('.private', '.controls').remove

          css('a + .method').each do |node|
            node.previous_element.replace("<h2>#{node.previous_element.to_html}</h2>")
          end
        else
          css('h2:empty + p').each do |node| # /customschematypes.html
            node.previous_element.content = node.content
            node.remove
          end

          at_css('h2').name = 'h1'

          css('h3').each do |node|
            node.name = 'h2'
          end
        end

        css('pre > code', 'h1 + ul', '.module', '.item', 'h3 > a', 'h3 code').each do |node|
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
