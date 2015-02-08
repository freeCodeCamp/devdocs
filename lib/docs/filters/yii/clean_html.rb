module Docs
  class Yii
    class CleanHtmlFilter < Filter
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

        doc
      end
    end
  end
end
