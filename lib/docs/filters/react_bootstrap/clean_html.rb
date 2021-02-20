module Docs
  class ReactBootstrap
    class CleanHtmlFilter < Filter
      def call
        css('.flex-column.d-flex').remove
        css('header').remove
        css('.bs-example').remove
        css('.position-relative').each do |node|
          code = node.at_css('textarea')
          code.name = 'pre'
          code['style'] = code['style'] + '; border: solid 1px;'
        end
        doc
      end
    end
  end
end
