module Docs
  class Typescript
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
        header = at_css('h1')
        header.parent.before(header).remove

        css('h4').each do |node|
          node.name = 'h2'
        end
      end

      def other
        @doc = at_css('article > .whitespace > .markdown')

        css('.anchor').remove

        css('a:contains("Try")').remove
        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = 'typescript'
          node.remove_attribute('class')
        end
      end
    end
  end
end
