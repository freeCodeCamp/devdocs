module Docs
  class Nokogiri2
    class CleanHtmlFilter < Docs::Rdoc::CleanHtmlFilter
      def root
        # Turn the collapsible navigation section into a plain list
        css('.nav-section-header').remove
        css('svg').remove
        css('details', 'summary').each do |node|
          node.before(node.children).remove
        end
      end
    end
  end
end
