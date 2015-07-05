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
        css('.element-invisible', '#sidebar-first', '#api-alternatives', '#aside', '.comments', '.view-filters',
            '#api-function-signature tr:not(.active)', '.ctools-collapsible-container', 'img[width="13"]').remove

        at_css('#main').replace(at_css('.content'))
        at_css('#page-heading').replace(at_css('#page-subtitle'))

        css('th.views-field > a', '.content').each do |node|
          node.before(node.children).remove
        end

        css('pre').each do |node|
          node.content = node.content
        end

        # Replaces the signature table from api.drupal.org with a simple pre tag
        css('#api-function-signature').each do |table|
          signature = table.css('.signature').first.at_css('code').inner_html
          table.replace '<pre class="signature">' + signature + '</pre>'
        end
      end
    end
  end
end
