module Docs
  class Html
    class CleanHtmlFilter < Filter
      def call
        css('span > .icon-thumbs-down-alt:first-child:last-child').each do |node|
          node.parent.replace('deprecated')
        end

        css('span > .icon-trash:first-child:last-child').each do |node|
          node.parent.replace('deleted')
        end

        css('span > .icon-warning-sign:first-child:last-child').each do |node|
          node.parent.replace('non standard')
        end

        doc
      end
    end
  end
end
