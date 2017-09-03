module Docs
  class Yii
    class CleanHtmlV2Filter < Filter
      def call
        css('.hashlink[name]').each do |node|
          node.parent['id'] = node['name']
        end

        css('#nav', '.tool-link', '.toggle', '.hashlink').remove

        css('.detail-header').each do |node|
          node.name = 'h3'
          node.child.remove while node.child.content.blank?
        end

        css('pre').each do |node|
          node.inner_html = node.inner_html.gsub('<br>', "\n").gsub('&nbsp;', ' ')
          node.content = node.content
          node['data-language'] = 'php'
        end

        css('div.signature').each do |node|
          node.name = 'pre'
          node.inner_html = node.inner_html.strip
        end

        css('.detail-table th').each do |node|
          node.name = 'td'
        end

        css('.detail-table td.signature').each do |node|
          node.name = 'th'
        end

        css('.summary', 'span[style]', 'div.doc-description', 'div.property-doc', 'div.class-description', 'th > span').each do |node|
          node.before(node.children).remove
        end

        css('a[id]:empty').each do |node|
          node.next_element['id'] = node['id'] if node.next_element && node.next_element.name != 'a'
        end

        css('table', 'pre', 'tr', 'td', 'th').remove_attr('class')

        doc
      end
    end
  end
end
