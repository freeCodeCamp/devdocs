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

        if at_css('#browser_compatibility') \
          and not at_css('#browser_compatibility').next_sibling.classes.include?('warning') \
          and not at_css('#browser_compatibility').next_sibling.content.match?('Supported')

          at_css('#browser_compatibility').next_sibling.remove

          compatibility_tables = generate_compatibility_table()
          compatibility_tables.each do |table|
            at_css('#browser_compatibility').add_next_sibling(table)
          end
        end

      end
    end
  end
end
