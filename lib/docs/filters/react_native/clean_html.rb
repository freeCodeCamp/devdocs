module Docs
  class ReactNative
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          at_css('h1').content = 'React Native Documentation'
          css('h1 ~ *').remove
        end

        css('.web-player').each do |node|
          node.before(node.children).remove
        end

        css('a pre').each do |node|
          node.name = 'code'
        end

        css('iframe', '.embedded-simulator', '.deprecatedIcon').remove

        doc
      end
    end
  end
end
