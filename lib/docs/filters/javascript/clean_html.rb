module Docs
  class Javascript
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
        css(*%w(#About_this_Reference+div #About_this_Reference
                #Typed_array_constructors+ul #Typed_array_constructors
                #Internationalization_constructors+ul #Internationalization_constructors
                #Comments~* #Comments)).remove

        # Move "Global Objects" lists to the same level as the other ones
        div = at_css '#Global_Objects + div'
        div.css('h3').each { |node| node.name = 'h2' }
        at_css('#Global_Objects').replace(div)

        # Remove heading links
        css('h2 > a').each do |node|
          node.before(node.content)
          node.remove
        end
      end

      def other
        css('.inheritsbox', '.overheadIndicator').each do |node|
          node.remove_attribute 'style'
        end
      end
    end
  end
end
