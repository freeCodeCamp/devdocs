module Docs
  class Vue
    class CleanHtmlFilter < Filter
      def call
        # Remove code highlighting
        css('figure').each do |node|
          node.name = 'pre'
          node.content = node.at_css('td.code pre').css('.line').map(&:content).join("\n")
        end
        css('.content')
      end
    end
  end
end
