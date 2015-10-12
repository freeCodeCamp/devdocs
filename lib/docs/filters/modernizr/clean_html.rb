module Docs
  class Modernizr
    class CleanHtmlFilter < Filter
      def call
        css('pre').each do |node|
          node.content = node.content
        end

        css('sub').each do |node|
          node.before(node.children).remove
        end

        css('td:nth-child(2)').each do |node|
          node.name = node.previous_element.name = 'th'
        end

        doc
      end
    end
  end
end
