module Docs
  class ReactNative
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          at_css('h1').content = 'React Native Documentation'
          css('h1 ~ *').remove
        end

        css('table h1', 'table h2', 'table h3').each do |node|
          table = node
          table = table.parent until table.name == 'table'
          table.replace(node)
        end

        css('blockquote > p:first-child').each do |node|
          node.remove if node.content.strip == 'Note:'
        end

        css('> div > div', '> div', 'div > span', '.props', '.prop', '> article', '.postHeader', '.web-player').each do |node|
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
