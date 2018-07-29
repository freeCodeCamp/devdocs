module Docs
  class Graphite
    class CleanHtmlFilter < Filter
      def call
        # Remove the paragraph icon after all headers
        css('.headerlink').remove

        css('dl.function > dt').each do |node|
          node.content = node.content
        end

        css('.section').each do |node|
          node.before(node.children).remove
        end

        css('div[class*="highlight-"]').each do |node|
          node.content = node.content.strip
          node.name = 'pre'
          node['data-language'] = node['class'][/highlight\-(\w+)/, 1]
          node.remove_attribute('class')
        end

        doc
      end
    end
  end
end
