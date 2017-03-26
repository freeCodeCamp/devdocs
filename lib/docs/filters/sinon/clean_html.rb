module Docs
  class Sinon
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          at_css('h1').content = 'Sinon.JS'
        else
          css('h1').each do |node|
            node.content = node.content.remove(' - Sinon.JS')
          end
        end

        css('.post', '.post-header', '.post-content', 'pre code').each do |node|
          node.before(node.children).remove
        end

        css('h1 + h1').remove

        css('pre').each do |node|
          node['data-language'] = 'javascript'
        end

        doc
      end
    end
  end
end
