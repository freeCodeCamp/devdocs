module Docs
  class Relay
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.inner-content, article.withtoc')

        if root_page?
          at_css('h1').content = 'Relay Documentation'
        end

        css('.docs-prevnext', '.hash-link', '.edit-page-link', '.edit-github', 'a.hash', '.edit-page-block', 'a.show', 'a.hide', 'hr').remove

        css('table h1', 'table h2', 'table h3').each do |node|
          table = node
          table = table.parent until table.name == 'table'
          table.replace(node)
        end

        css('a.anchor', 'a.hashref').each do |node|
          node.parent['id'] ||= node['name'] || node['id']
        end

        css('.highlight').each do |node|
          node.name = 'pre'
          node.css('.gutter').remove
          node['data-language'] = node.at_css('[data-lang]').try(:[], 'data-lang') || 'js'
          node.content = node.content.strip
        end

        css('table.highlighttable').each do |node|
          node.replace(node.at_css('pre.highlight'))
        end

        css('.prism').each do |node|
          node.name = 'pre'
          node['data-language'] = node['class'][/(?<=language\-)(\w+)/]
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

        css('a pre', 'h3 .propType').each do |node|
          node.name = 'code'
        end

        css('a[target]').each do |node|
          node.remove_attribute('target')
        end

        doc
      end
    end
  end
end
