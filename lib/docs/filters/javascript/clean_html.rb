module Docs
  class Javascript
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
        # Move "Global Objects" lists to the same level as the other ones
        css('#Global_Objects + p').remove
        div = at_css '#Global_Objects + div'
        div.css('h3').each { |node| node.name = 'h2' }
        at_css('#Global_Objects').replace(div.children)
      end

      def other
        # Remove "style" attribute
        css('.inheritsbox', '.overheadIndicator').each do |node|
          node.remove_attribute 'style'
        end

        # Remove <div> wrapping .overheadIndicator
        css('div > .overheadIndicator:first-child:last-child').each do |node|
          node.parent.replace(node)
        end
      end
    end
  end
end
