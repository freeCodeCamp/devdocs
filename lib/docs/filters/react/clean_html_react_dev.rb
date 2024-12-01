module Docs
  class React
    class CleanHtmlReactDevFilter < Filter
      def call
        @doc = at_css('article')

        # Remove breadcrumbs before h1
        css('h1').each do |node|
          node.previous.remove
        end

        # Remove prev-next links
        css('div.grid > a').each do |node|
          node.remove
        end

        # Remove styling divs
        css('div[class*="ps-0"]', 'div[class*="mx-"]', 'div[class*="px-"]', 'div[class=""]', 'div.cm-line').each do |node|
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
