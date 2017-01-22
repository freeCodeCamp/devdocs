module Docs
  class Http
    class CleanHtmlFilter < Filter
      def call
        current_url.host == 'tools.ietf.org' ? ietf : mdn
        doc
      end

      def mdn
        css('.column-container', '.column-half').each do |node|
          node.before(node.children).remove
        end

        css('p > code + strong').each do |node|
          code = node.previous_element
          if code.content =~ /\A[\s\d]+\z/
            code.content = "#{code.content.strip} #{node.content.strip}"
            node.remove
          end
        end

        css('strong > code').each do |node|
          node.parent.before(node.parent.children).remove
        end
      end

      def ietf
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
      end
    end
  end
end
