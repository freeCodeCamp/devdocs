module Docs
  class ApachePig
    class CleanHtmlFilter < Filter
      def call
        css('.pdflink').remove

        css('a[name]').each do |node|
          node.next_element['id'] = node['name']
        end

        css('h2', 'h3').each do |node|
          node.remove_attribute 'class'
        end

        css('table').each do |node|
          node.remove_attribute 'cellspacing'
          node.remove_attribute 'cellpadding'
        end

        doc
      end
    end
  end
end
