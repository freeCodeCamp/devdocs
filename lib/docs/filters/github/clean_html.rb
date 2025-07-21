module Docs
  class Github
    class CleanHtmlFilter < Filter
      def call
        # Remove h1 wrapper to render it correctly.
        css('.markdown-heading h1').each do |node|
          node.parent.replace(node)
        end

        css('.anchor').each do |node|
          node.parent['id'] = node['href'].remove('#')
          node.remove
        end

        css('.highlight > pre').each do |node|
          node['data-language'] = node.parent['class'][/highlight-source-(\w+)/, 1]
          node.content = node.content.strip_heredoc
          node.parent.replace(node)
        end

        css('pre > code').each do |node|
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
