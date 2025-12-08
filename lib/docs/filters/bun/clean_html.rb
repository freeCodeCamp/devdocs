module Docs
  class Bun
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#content-area')
        doc.children = css('#header, #content')

        header = at_css('header:has(h1)')
        if header
          header.content = header.at_css('h1').content
          header.name = 'h1'
        end

        css('*[aria-label="Navigate to header"]', '*[aria-label="Copy the contents from the code block"]').each do |node|
          node.parent.remove
        end
        css('img').remove
        css('svg').remove
        
        css('.code-block *[data-component-part="code-block-header"]').remove
        css('.code-block', '.code-group').each do |node|
          node.name = 'pre'
          node.content = node.content
          node['data-language'] = 'typescript'
          node.remove_attribute('style')
        end

        css('.font-mono').each do |node|
          node.name = 'code'
          node.content = node.content
        end

        css('.font-mono.text-blue-600').each do |node|
          node[:class] = 'token keyword'
        end

        css('*[class]').each do |node|
          next if node.name == 'code'
          node.remove_attribute('class')
        end

        doc
      end
    end
  end
end
