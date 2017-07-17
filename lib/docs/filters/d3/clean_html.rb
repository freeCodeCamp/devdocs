module Docs
  class D3
    class CleanHtmlFilter < Filter
      def call
        css('p:contains("This page describes the D3 3.x API.")').remove

        # Remove links inside <h2> and add "id" attributes
        css('a.anchor').each do |node|
          node.parent['id'] = (node['id'] || node['name']).remove('user-content-') if node['id'] || node['name']
          node.before(node.children).remove
        end

        # Make headings for function definitions and add "id" attributes
        css('p > a:first-child').each do |node|
          next unless node.parent
          next unless node['name'] || node.content == '#'
          parent = node.parent
          parent.name = 'h6'
          parent['id'] = (node['name'] || node['href'].remove(/\A.+#/)).remove('user-content-')
          parent.css('a[name], a:contains("#"), a:contains("†")').remove
          node.remove
        end

        css('h4').each { |node| node.name = 'h3' } if root_page?

        css('a > img').each do |node|
          node.parent.before(node).remove
        end

        css('h6 a[title="Source"]').each do |node|
          node.content = 'Source'
          node['class'] = 'source'
        end

        # Fix internal links
        css('a[href]').each do |node|
          node['href'] = node['href'].sub(/#user\-content\-(\w+?)\z/, '#\1').sub(/#wiki\-(\w+?)\z/, '#\1')
        end

        # Remove code highlighting
        css('.highlight > pre').each do |node|
          node.content = node.content
          node['data-language'] = if node.parent['class'].include?('html')
            'markup'
          elsif node.parent['class'].include?('css')
            'css'
          else
            'javascript'
          end
          node.parent.before(node).remove
        end

        css('pre > code').each do |node|
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
