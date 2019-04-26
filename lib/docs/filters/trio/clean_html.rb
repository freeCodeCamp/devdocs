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
          if node.parent.classes.include? 'class'
            new_node = doc.document.create_element 'h2'
          else
            new_node = doc.document.create_element "h3"
          end
          new_node['id'] = node['id']
          new_node.content = node.inner_text
          node.replace new_node
        end

        css('pre').each do |node|
          classes = node.parent.parent.classes
          if classes.include? 'highlight-python3'
            node['class'] = 'language-python'
            node['data-language'] = 'python'
          end
          node.parent.parent.replace(node)
        end
        doc
      end
    end
  end
end
