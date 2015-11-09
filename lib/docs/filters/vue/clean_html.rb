module Docs
  class Vue
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.content')

        at_css('h1').content = 'Vue.js' if root_page?

        css('.demo', '.guide-links', '.footer').remove

        # Remove code highlighting
        css('figure').each do |node|
          node.name = 'pre'
          node.content = node.at_css('td.code pre').css('.line').map(&:content).join("\n")
        end

        doc
      end
    end
  end
end
