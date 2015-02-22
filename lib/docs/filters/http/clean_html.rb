module Docs
  class Http
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          doc.inner_html = '<h1>Hypertext Transfer Protocol</h1>'
          return doc
        end

        doc.child.remove while doc.child.name != 'pre'

        css('span.grey', '.invisible', '.noprint', 'a[href^="#page-"]').remove

        css('pre').each do |node|
          content = node.inner_html.remove(/\A(\ *\n)+/).remove(/(\n\ *)+\z/)
          node.before("\n\n" + content).remove
        end

        css('span[class^="h"]').each do |node|
          i = node['class'][/\Ah(\d)/, 1].to_i
          next unless i > 0
          node.name = "h#{i}"
          node.inner_html = node.inner_html.strip
          node.next.content = node.next.content.remove(/\A\n/) if node.next.text?
        end

        css('.selflink').each do |node|
          node.parent['id'] = node['name']
          node.before(node.children).remove
        end

        html = doc.inner_html.strip
        html.remove! %r[\.{2,}$]
        html.gsub! %r[(^\n$){3,}], "\n"
        doc.inner_html = %(<div class="_rfc-pre">#{html}</div>)

        doc
      end
    end
  end
end
