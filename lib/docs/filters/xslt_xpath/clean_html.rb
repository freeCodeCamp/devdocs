module Docs
  class XsltXpath
    class CleanHtmlFilter < Filter
      def call
        initial_page? ? root : other
        doc
      end

      def root
        if table = at_css('.topicpage-table')
          table.after(table.css('td').children).remove
        end
      end

      def other
        css('div[style*="background: #f5f5f5;"]').remove

        css('h3[id]').each do |node|
          node.name = 'h2'
        end

        css('p').each do |node|
          child = node.child
          child = child.next while child && child.text? && child.content.blank?
          child.remove if child.try(:name) == 'br'
        end
      end
    end
  end
end
