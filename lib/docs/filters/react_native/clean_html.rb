module Docs
  class ReactNative
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          css('h1 ~ *').remove
        end

        css('center > .button', 'p:contains("short survey")', 'iframe', '.embedded-simulator', '.deprecatedIcon').remove

        css('h4.methodTitle').each do |node|
          node.name = 'h3'
        end

        css('div:not([class])', 'span:not([class])').each do |node|
          node.before(node.children).remove
        end

        css('ul').each do |node|
          node.before(node.children).remove if node.at_css('> p', '> h2')
        end

        doc
      end
    end
  end
end
