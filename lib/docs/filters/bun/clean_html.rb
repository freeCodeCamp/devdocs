module Docs
  class Bun
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('section > .w-full')

        header = at_css('header:has(h1)')
        if header
          header.content = header.at_css('h1').content
          header.name = 'h1'
        end

        css('.CodeBlockTab').remove
        css('.CopyIcon').remove
        css('svg').remove
        css('a:contains("Edit on GitHub")').remove
        css('a:contains("Previous")').remove
        css('a:contains("Next")').remove

        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = 'typescript'
          node.remove_attribute('style')
        end

        css('.font-mono').each do |node|
          node.name = 'code'
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
