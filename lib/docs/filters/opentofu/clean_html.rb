module Docs
  class Opentofu
    class CleanHtmlFilter < Filter
      def fix_syntax_highlight
        css('pre').each do |node|
          node.remove_attribute('class')
          node.remove_attribute('style')
          node.css('.token-line').remove_attribute('style')
        end

        css('[class*="buttonGroup_"]').remove
      end

      # Some SVG icons are just too big and not needed.
      def remove_svg_icons
        css('[role="alert"] svg').remove
      end

      def call
        @doc = at_css("main article > .prose")

        remove_svg_icons
        fix_syntax_highlight

        doc
      end
    end
  end
end
