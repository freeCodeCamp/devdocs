module Docs
  class ReactNative
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('main .col .markdown')

        if root_page?
          at_css('h1').content = 'React Native Documentation'
          css('h1 ~ *').remove
        end

        css('header').each do |node|
          node.before(node.children).remove
        end

        css('.content-banner-img').remove
        css('.anchor').remove_attribute('class')
        css('button[aria-label="Copy code to clipboard"]').remove
        css('h2#example').remove

        css('pre').each do |node|
          node.content = node.css('.token-line').map(&:content).join("\n")
          node.remove_attribute('class')
          node['data-language'] = 'jsx'
        end

        #

        css('.docs-prevnext', '.hash-link', '.edit-page-link', '.edit-github', 'a.hash', '.edit-page-block', 'a.show', 'a.hide', 'hr').remove

        css('table h1', 'table h2', 'table h3').each do |node|
          table = node
          table = table.parent until table.name == 'table'
          table.replace(node)
        end

        css('a.anchor', 'a.hashref').each do |node|
          node.parent['id'] ||= node['name'] || node['id']
        end

        css('table.highlighttable').each do |node|
          node.replace(node.at_css('pre.highlight'))
        end

        css('pre > code.hljs').each do |node|
          node.parent['data-language'] = 'jsx'
          node.before(node.children).remove
        end

        css('blockquote > p:first-child').each do |node|
          node.remove if node.content.strip == 'Note:'
        end

        css('h3#props', 'h3#methods').each { |node| node.name = 'h2' }
        css('h4.propTitle').each { |node| node.name = 'h3' }

        css('> div > div', '> div', 'div > span', '.props', '.prop', '> article', '.postHeader', '.web-player').each do |node|
          node.before(node.children).remove
        end

        css('a pre', 'h3 .propType').each do |node|
          node.name = 'code'
        end

        css('a[target]').each do |node|
          node.remove_attribute('target')
        end

        css('center > .button', 'p:contains("short survey")', 'iframe', '.embedded-simulator', '.deprecatedIcon').remove

        css('h4.methodTitle').each do |node|
          node.name = 'h3'
        end

        css('div:not([class])', 'span:not([class])').each do |node|
          node.before(node.children).remove
        end

        css('ul').each do |node|
          node.before(node.children).remove if node.at_css('> p', '> h2')
        end

        doc
      end
    end
  end
end
