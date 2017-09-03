module Docs
  class Influxdata
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          doc.inner_html = ' '
          return doc
        end

        doc = @doc.at_css('article')

        css('.article-footer', 'hr', 'br').remove

        css('a.offset-anchor').each do |node|
          node.parent['id'] = node['id']
        end

        css('.article-content', '.article-section', 'font').each do |node|
          node.before(node.children).remove
        end

        css('pre > code').each do |node|
          node.parent['data-language'] = node['class'][/language-(\w+)/, 1] if node['class']
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
