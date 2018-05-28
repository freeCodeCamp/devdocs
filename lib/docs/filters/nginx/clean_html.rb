module Docs
  class Nginx
    class CleanHtmlFilter < Filter
      def call
        at_css('h2').name = 'h1'

        css('center').each do |node|
          node.before(node.children).remove
        end

        css('blockquote > pre', 'blockquote > table:only-child').each do |node|
          node.parent.before(node).remove
        end

        css('a[name]').each do |node|
          node.next_element['id'] = node['name']
          node.remove
        end

        links = css('h1 + table > tr:only-child > td:only-child > a').map(&:to_html)
        if links.present?
          at_css('h1 + table').replace("<ul><li>#{links.join('</li><li>')}</li></ul>")
        end

        css('td > pre').each do |node|
          node.name = 'code'
        end

        css('pre').each do |node|
          node['data-language'] = 'nginx'
        end

        css('code code').each do |node|
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
