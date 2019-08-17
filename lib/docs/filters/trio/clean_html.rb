module Docs
  class Trio
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('div[role="main"]')

        css('.section, [itemprop=articleBody]').each do |node|
          node.replace node.children
        end

        css('.headerlink').remove

        css('dt').each do |node|
          node.name = 'h3'

          if node.parent.classes.include? 'field-list'
            node.name = 'h4'
            node['style'] = 'margin: 0'

            if node.text == 'Parameters' or node.text == 'Raises'
              node.next_element.css('strong').each do |n|
                n.name = 'code'
              end
            end
          else
            code = doc.document.create_element 'code'

            if em = node.at_css('.property')
              code.inner_html = "<em>#{em.text.strip}</em> "
              em.remove
            end

            code.inner_html += node.inner_text.strip
            node.inner_html = code
          end
        end

        css('pre').each do |node|
          node.content = node.content.strip

          classes = node.parent.parent.classes
          if classes.include? 'highlight-python3'
            node['data-language'] = 'python'
          end

          node.parent.parent.replace(node)
        end

        css('.admonition').each do |node|
          node.name = 'blockquote'
          node.at_css('.admonition-title').name = 'h4'
        end

        doc
      end
    end
  end
end
