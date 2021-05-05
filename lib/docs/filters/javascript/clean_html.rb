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
      end
    end
  end
end
