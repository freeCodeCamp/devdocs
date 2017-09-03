module Docs
  class Drupal
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
        doc.inner_html = ' '
      end

      def other
        css('.element-invisible',
            '#sidebar-first',
            '#api-alternatives',
            '#aside',
            '.comments',
            '.view-filters',
            '#api-function-signature tr:not(.active)',
            '.ctools-collapsible-container',
            'img[width="13"]',
            'a:contains("Expanded class hierarchy")',
            'a:contains("All classes that implement")'
        ).remove

        at_css('#main').replace(at_css('.content'))
        at_css('#page-heading').replace(at_css('#page-subtitle'))

        css('th.views-field > a', '.content', 'ins', '.view', '.view-content', 'div.item-list').each do |node|
          node.before(node.children).remove
        end

        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = 'php'
        end

        css('#api-function-signature').each do |table|
          signature = table.css('.signature').first.at_css('code').inner_html
          table.replace '<pre class="signature">' + signature + '</pre>'
        end

        css('table[class]', 'tr[class]', 'td[class]', 'th[class]').each do |node|
          node.remove_attribute('class')
        end
      end
    end
  end
end
