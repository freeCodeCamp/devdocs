module Docs
  class Javascript
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
      end

      def other
        # Remove "style" attribute
        css('.inheritsbox', '.overheadIndicator', '.blockIndicator').each do |node|
          node.remove_attribute 'style'
        end

        # Remove <div> wrapping .overheadIndicator
        css('div > .overheadIndicator:first-child:last-child', 'div > .blockIndicator:first-child:last-child').each do |node|
          node.parent.replace(node)
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
