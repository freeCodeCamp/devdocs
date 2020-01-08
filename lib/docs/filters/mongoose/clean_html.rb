module Docs
  class Mongoose
    class CleanHtmlFilter < Filter
      def call
        css('hr', '.showcode', '.sourcecode').remove

        css('h2:empty + p').each do |node| # /customschematypes.html
          node.previous_element.content = node.content
          node.remove
        end

        css('pre > code', 'h1 + ul', '.module', '.item', 'h1 > a', 'h2 > a', 'h3 > a', 'h3 code').each do |node|
          node.before(node.children).remove
        end

        css('pre').each do |node|
          node['data-language'] = 'javascript'
        end

        css('.native-inline', '.api-nav', '.toc', '.api-content ul:first-child').remove

        if !at_css('h1')
          if css('h2').count > 1
            # Mongoose vX.Y.Z: [title here]
            title = doc.document.at_css('title').content.split(': ')[1]
            doc.prepend_child("<h1>#{title}</title>")
          else
            at_css('h2').name = 'h1'
            css('h3').each do |el|
              el.name = 'h2'
            end
          end
        end

        doc
      end
    end
  end
end
