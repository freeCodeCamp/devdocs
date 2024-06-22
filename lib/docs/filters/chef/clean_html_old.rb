module Docs
  class Chef
    class CleanHtmlOldFilter < Filter
      def call
        @doc = at_css('div[role="main"]')

        css('.headerlink').remove

        css('em', 'div.align-center', 'a[href$=".svg"]').each do |node|
          node.before(node.children).remove
        end

        css('.section').each do |node|
          node.first_element_child['id'] = node['id'] if node['id']
          node.before(node.children).remove
        end

        css('tt').each do |node|
          node.content = node.content.strip
          node.name = 'code'
        end

        css('table[border]').each do |node|
          node.remove_attribute('border')
        end

        css('div[class*="highlight-"]').each do |node|
          node.content = node.content.strip
          node.name = 'pre'
          node['data-language'] = node['class'][/highlight\-(\w+)/, 1]
        end

        doc
      end
    end
  end
end
