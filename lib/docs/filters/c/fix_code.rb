module Docs
  class C
    class FixCodeFilter < Filter
      def call
        css('div > span.source-c', 'div > span.source-cpp').each do |node|
          node.inner_html = node.inner_html.gsub(/<br>\n?/, "\n").gsub("\n</p>\n", "</p>\n")
          node.parent.name = 'pre'
          node.parent['class'] = node['class']
          node.parent.content = node.content
        end

        nbsp = Nokogiri::HTML('&nbsp;').text
        css('pre').each do |node|
          node.content = node.content.gsub(nbsp, ' ')
        end

        doc
      end
    end
  end
end
