module Docs
  class Dom
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
      end

      def other
        # Bug fix: HTMLElement.offsetWidth
        css('#offsetContainer .comment').remove

        # Bug fix: CompositionEvent, DataTransfer, etc.
        if (div = at_css('div[style]')) && div['style'].include?('border: solid #ddd 2px')
          div.remove
        end

        # Remove double heading on SVG pages
        if slug.start_with? 'SVG'
          at_css('h2:first-child').try :remove
        end

        # Remove <div> wrapping .overheadIndicator
        css('div > .overheadIndicator:first-child:last-child').each do |node|
          node.parent.replace(node)
        end
      end
    end
  end
end
