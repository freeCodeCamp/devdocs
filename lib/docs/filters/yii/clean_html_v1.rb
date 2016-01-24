module Docs
  class Yii
    class CleanHtmlV1Filter < Filter
      def call
        at_css('h1').content = 'Yii PHP Framework' if root_page?

        css('.api-suggest', '.google-ad', '.g-plusone', '#nav', '#comments').remove

        css('.summary > p > .toggle').each do |node|
          node.parent.remove
        end

        css('.signature', '.signature2').each do |node|
          node.name = 'pre'
          node.inner_html = node.inner_html.strip
        end

        css('div.detailHeader').each do |node|
          node.name = 'h3'
        end

        css('.sourceCode > .code > code').each do |node|
          parent = node.parent
          parent.name = 'pre'
          node.remove
          parent.inner_html = node.first_element_child.inner_html.strip
        end

        doc
      end
    end
  end
end
