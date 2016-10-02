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

        css('.NAVHEADER', 'hr', '.NAVFOOTER a[accesskey="H"]').remove

        css('a[name]').each do |node|
          node.parent['id'] = node['name']
          node.before(node.children).remove
        end

        css('div.SECT1', 'pre > kbd', 'tt > code', 'h1 > tt', '> .CHAPTER', 'div.NOTE', '.APPENDIX').each do |node|
          node.before(node.children).remove
        end

        css('div.CAUTION table.CAUTION').each do |node|
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

        css('tt').each do |node|
          node.name = 'code'
        end

        css('.REFSYNOPSISDIV > p').each do |node|
          node.name = 'pre'
          node.content = node.content
        end

        css('pre code', 'pre span').each do |node|
          node.before(node.children).remove
        end

        css('pre.SYNOPSIS', 'pre.PROGRAMLISTING').each do |node|
          node['data-language'] = 'sql'
        end
      end
    end
  end
end
