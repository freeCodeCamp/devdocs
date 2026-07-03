module Docs
  class Http
    class CleanHtmlFilter < Filter
      def call
        current_url.host == 'datatracker.ietf.org' ? ietf : mdn
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
        # datatracker serves two layouts: a legacy plain-text rendering wrapped
        # in .rfcmarkup (older RFCs) and a modern structured HTML rendering
        # wrapped in .rfchtml (RFCs with xml2rfc v3 sources, e.g. RFC 9110+).
        doc['class'].to_s.include?('rfchtml') ? ietf_html : ietf_text
      end

      def ietf_html
        css('.pilcrow', '.noprint').remove
      end

      def ietf_text
        @doc = at_css('.rfcmarkup')
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
          node.parent['id'] = node['id']
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
