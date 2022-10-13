module Docs
  class Postgresql
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
        doc.inner_html = ' '
      end

      def other
        @doc = at_css('#docContent')

        css('.navheader', 'hr', '.navfooter a[accesskey="H"]', '.navfooter').remove

        unless at_css('h1')
          at_css('.refnamediv h2, .titlepage h2').name = 'h1'
        end

        css('a[name]').each do |node|
          node.parent['id'] = node['name']
          node.before(node.children).remove
        end

        css('div.sect1', '.refentry', '.refnamediv', '.refentrytitle', '.refsynopsisdiv', 'pre > kbd', 'tt > code', 'h1 > tt', '> .chapter', '.appendix', '.titlepage', 'div:not([class]):not([id])', 'br', 'a.indexterm', 'acronym', '.productname', 'div.itemizedlist', 'span.sect2', 'span.application', 'em.replaceable', 'span.term').each do |node|
          node.before(node.children).remove
        end

        css('div.caution table.caution').each do |node|
          parent = node.parent
          title = node.at_css('.c2, .c3, .c4, .c5').content
          node.replace(node.css('p'))
          parent.first_element_child.inner_html = "<strong>#{title}:</strong> #{parent.first_element_child.inner_html}"
          parent.name = 'blockquote'
        end

        css('table').each do |node|
          node.remove_attribute 'border'
          node.remove_attribute 'width'
          node.remove_attribute 'cellspacing'
          node.remove_attribute 'cellpadding'
        end

        css('td').each do |node|
          node.remove_attribute 'valign'
        end

        css('.sect2 > h3').each do |node|
          node.name = 'h2'
        end

        css('.sect3 > h4').each do |node|
          node.name = 'h3'
        end

        css('tt').each do |node|
          node.name = 'code'
        end

        css('div.note', 'div.important', 'div.tip', 'div.caution').each do |node|
          if node.at_css('blockquote')
            node.before(node.children).remove
          else
            node.name = 'blockquote'
          end
        end

        css('.refsynopsisdiv > p').each do |node|
          node.name = 'pre'
          node.content = node.content
        end

        css('pre code', 'pre span', 'pre i', 'pre samp', 'code code', 'code span').each do |node|
          node.before(node.children).remove
        end

        css('code').each do |node|
          node.inner_html = node.inner_html.gsub(/\s*\n\s*/, ' ')
        end

        css('pre.synopsis', 'pre.programlisting').each do |node|
          node['data-language'] = 'sql'
        end

        css('h1', 'ul', 'li', 'pre').each do |node|
          node.remove_attribute 'class'
          node.remove_attribute 'style'
        end
      end
    end
  end
end
