module Docs
  class Playwright
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.markdown')

        css('x-search').remove
        css('hr').remove
        css('font:contains("Added in")').remove
        css('.list-anchor').remove

        css('.alert').each do |node|
          node.name = 'blockquote'
        end

        css('pre').each do |node|
          node.content = node.css('.token-line').map(&:content).join("\n")
          node.remove_attribute('style')
          node['data-language'] = node.content =~ /\A\s*</ ? 'html' : 'javascript'
          node.ancestors('.theme-code-block').first.replace(node)
        end

        css('*[class]').remove_attribute('class')

        doc
      end
    end
  end
end
