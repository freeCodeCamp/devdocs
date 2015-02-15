module Docs
  class Clojure
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          doc.inner_html = '<h1>Clojure</h1>'
          return doc
        end

        @doc = at_css('#content-tag')

        at_css('h1').content = slug.remove('-api')

        css('> div').each do |node|
          node.before(node.children).remove
        end

        css('div > h2', 'div > h3').each do |node|
          node.parent.before(node.parent.children).remove
        end

        css('#proto-type', '#var-type', '#type-type').each do |node|
          node.previous_element << node
          node['class'] = 'type'
        end

        css('.proto-added', '.var-added', '.proto-deprecated', '.var-deprecated').each do |node|
          node.content = node.content
          node.name = 'p'
        end

        css('.proto-added', '.var-added').each do |node|
          if node.content == node.next_element.try(:content)
            node.remove
          end
        end

        css('hr', 'br:first-child', 'pre + br', 'h1 + br', 'h2 + br', 'h3 + br', 'p + br', 'br + br').remove

        doc
      end
    end
  end
end
