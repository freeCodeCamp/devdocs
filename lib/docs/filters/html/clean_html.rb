module Docs
  class Html
    class CleanHtmlFilter < Filter
      def call
        css('section', 'div.section', 'div.row').each do |node|
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
