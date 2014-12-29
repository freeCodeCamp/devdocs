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

        css('.NAVHEADER', '.NAVFOOTER').remove

        css('a[name]').each do |node|
          node.parent['id'] = node['name']
          node.before(node.children).remove
        end

        css('div.SECT1', 'pre > kbd', 'tt > code', 'h1 > tt').each do |node|
          node.before(node.children).remove
        end

        css('table').each do |node|
          node.remove_attribute 'border'
          node.remove_attribute 'width'
        end

        css('td').each do |node|
          node.remove_attribute 'align'
          node.remove_attribute 'valign'
        end

        css('tt').each do |node|
          node.name = 'code'
        end

        css('.REFSYNOPSISDIV > p').each do |node|
          node.name = 'pre'
          node.content = node.content
        end
      end
    end
  end
end
