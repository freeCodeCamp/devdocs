module Docs
  class Typescript
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.doc-content-container')

        if root_page?
          at_css('h1').content = 'TypeScript Documentation'
        end

        css('.xs-toc-container').remove

        css('article h1').each do |node|
          node.name = 'h2'
        end

        css('> header', '> article').each do |node|
          node.before(node.children).remove
        end

        css('pre > code').each do |node|
          node.parent['data-language'] = node['class'].sub('ts', 'typescript').sub('js', 'javascript').remove('language-')
          node.content = node.content.gsub('    ', '  ')
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
