module Docs
  class Cppref
    class FixCodeFilter < Filter
      def call
        css('div > span.source-c', 'div > span.source-cpp').each do |node|
          if (node.parent.classes||[]).none?{|className| ['t-li1','t-li2','t-li3'].include?(className) }
            node.inner_html = node.inner_html.gsub(/<br>\n?/, "\n").gsub("\n</p>\n", "</p>\n")
            node.parent.name = 'pre'
            node.parent['class'] = node['class']
            node.parent.content = node.content
          end
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
