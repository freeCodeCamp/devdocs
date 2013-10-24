module Docs
  class Html
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
        css('p').each do |node|
          node.remove if node.content.lstrip.start_with? 'The symbol'
        end
      end

      def other
      end
    end
  end
end
