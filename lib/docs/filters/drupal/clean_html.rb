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
        css('#page-title-tools', '.element-invisible', '.breadcrumb', '#sidebar-first', '#api-alternatives').remove
        css('#aside', '#api-function-signature tr:not(.active)', '.comments').remove
        # Replaces the signature table from api.drupal.org with a simple pre tag
        css('#api-function-signature').each do |table|
          signature = table.css('.signature').first.inner_html
          table.replace '<pre class="signature">' + signature + '</pre>'
        end
      end
    end
  end
end
