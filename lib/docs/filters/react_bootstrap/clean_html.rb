module Docs
  class ReactBootstrap
    class CleanHtmlFilter < Filter
      def call
        css('.flex-column.d-flex').remove
        css('header').remove
        css('.bs-example').remove

        css('.position-relative pre').each do |node|
          # node.content = node.content
          node.remove_attribute('style')
          node['data-language'] = 'jsx'
          node.parent.replace(node)
        end
        doc
      end
    end
  end
end
