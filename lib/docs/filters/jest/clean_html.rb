module Docs
  class Jest
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.mainContainer .post')

        at_css('h1').content = 'Jest' if root_page?

        css('.edit-page-link', '.hash-link', 'hr').remove

        css('.postHeader', 'article', 'div:not([class])').each do |node|
          node.before(node.children).remove
        end

        css('.anchor').each do |node|
          node.parent['id'] = node['id']
          node.remove
        end

        css('pre').each do |node|
          node['data-language'] = 'js'
          node['data-language'] = node['class'][/language-(\w+)/, 1] if node['class']
          node.content = node.content
        end

        doc
      end
    end
  end
end
