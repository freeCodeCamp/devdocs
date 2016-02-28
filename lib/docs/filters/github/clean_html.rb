module Docs
  class Github
    class CleanHtmlFilter < Filter
      def call
        css('.anchor').each do |node|
          node.parent['id'] = node['href'].remove('#')
          node.remove
        end

        css('.highlight > pre').each do |node|
          node['class'] = node.parent['class']
          node.content = node.content.strip_heredoc.gsub('    ', '  ')
          node.parent.replace(node)
        end

        doc
      end
    end
  end
end
