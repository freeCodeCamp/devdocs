module Docs
  class D3
    class CleanHtmlFilter < Filter
      def call
        # Remove links inside <h2> and add "id" attributes
        css('h2 > a').each do |node|
          node.parent['id'] = node['name'].remove('user-content-') if node['name']
          node.before(node.children).remove
        end

        css('.markdown-body > blockquote:first-child', '.anchor').remove

        # Replace .gh-header with <h1>
        css('.gh-header-title').each do |node|
          node.parent.parent.before(node).remove
          node.content = 'D3.js' if root_page?
        end

        # Move content to the root-level
        css('#wiki-content').each do |node|
          node.before(node.at_css('.markdown-body').children).remove
        end

        # Make headings for function definitions and add "id" attributes
        css('p > a:first-child').each do |node|
          next unless node['name'] || node.content == '#'
          parent = node.parent
          parent.name = 'h6'
          parent['id'] = (node['name'] || node['href'].remove(/\A.+#/)).remove('user-content-')
          parent.css('a[name]').remove
          node.remove
        end

        # Fix internal links
        css('a[href]').each do |node|
          node['href'] = node['href'].sub(/#user\-content\-(\w+?)\z/, '#\1').sub(/#wiki\-(\w+?)\z/, '#\1')
        end

        # Remove code highlighting
        css('.highlight > pre').each do |node|
          node.content = node.content
        end

        doc
      end
    end
  end
end
