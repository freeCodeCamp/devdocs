module Docs
  class Q
    class CleanHtmlFilter < Filter
      def call
        css('.anchor').each do |node|
          node.parent['id'] = node['href'].remove('#')
          node.remove
        end

        css('.highlight > pre').each do |node|
          node.content = node.content.gsub('    ', '  ')
        end

        doc
      end
    end
  end
end
