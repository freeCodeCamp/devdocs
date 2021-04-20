module Docs
  class Html
    class CleanHtmlFilter < Filter
      def call
        css('section', 'div.section', 'div.row').each do |node|
          node.before(node.children).remove
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

        doc
      end
    end
  end
end
