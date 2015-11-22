module Docs
  class React
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.inner-content, article.withtoc')

        if root_page?
          at_css('h1').content = context[:root_title]
        end

        css('.docs-prevnext', '.hash-link', '.edit-page-link', '.edit-github').remove

        css('a.anchor').each do |node|
          node.parent['id'] = node['name']
        end

        css('.highlight').each do |node|
          node.name = 'pre'
          node['data-lang'] = node.at_css('[data-lang]').try(:[], 'data-lang') || 'js'
          node.content = node.content
        end

        css('table.highlighttable').each do |node|
          node.replace(node.at_css('pre.highlight'))
        end

        css('.prism').each do |node|
          node.name = 'pre'
          node['data-lang'] = node['class'][/(?<=language\-)(\w+)/]
          node.content = node.content
        end

        css('blockquote > p:first-child').each do |node|
          node.remove if node.content.strip == 'Note:'
        end

        css('h3#props', 'h3#methods').each { |node| node.name = 'h2' }
        css('h4.propTitle').each { |node| node.name = 'h3' }

        css('> div > div', '> div', 'div > span', '.props', '.prop').each do |node|
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
