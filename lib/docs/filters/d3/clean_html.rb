module Docs
  class D3
    class CleanHtmlFilter < Filter
      def call
        css('#gollum-footer', '.markdown-body > blockquote:first-child', '.anchor').remove

        # Replace #head with <h1>
        css('#head > h1').each do |node|
          node.parent.before(node).remove
          node.content = 'D3.js' if root_page?
        end

        # Move content to the root-level
        css('#wiki-content').each do |node|
          node.before(node.at_css('.markdown-body').children).remove
        end

        # Remove links inside <h2>
        css('h2 > a').each do |node|
          node.before(node.children).remove
        end

        # Make headings for function definitions and add "id" attributes
        css('p > a:first-child').each do |node|
          next unless node['name'] || node.content == '#'
          parent = node.parent
          parent.name = 'h6'
          parent['id'] = (node['name'] || node['href'].sub(/\A.+#/, '')).sub('wiki-', '')
          parent.css('a[name]').remove
          node.remove
        end

        # Make headings for function definitions and add "id" attributes
        css('p > a:first-child').each do |node|
          next unless node['name'] || node.content == '#'
          parent = node.parent
          parent.name = 'h6'
          parent['id'] = (node['name'] || node['href'].sub(/\A.+#/, '')).sub('wiki-', '')
          parent.css('a[name]').remove
          node.remove
        end

        # Fix internal links
        css('a[href]').each do |node|
          node['href'] = node['href'].sub(/#wiki\-(\w+?)\z/, '#\1')
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
