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
        css('span > .icon-thumbs-down-alt:first-child:last-child').each do |node|
          node.parent.replace('deprecated')
        end

        css('span > .icon-trash:first-child:last-child').each do |node|
          node.parent.replace('deleted')
        end

        css('span > .icon-warning-sign:first-child:last-child').each do |node|
          node.parent.replace('non standard')
        end
      end
    end
  end
end
