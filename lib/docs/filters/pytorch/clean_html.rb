module Docs
  class Pytorch
    class CleanHtmlFilter < Filter
      def call
        if root = at_css('#pytorch-article')
          @doc = root
          # Show katex-mathml nodes and remove katex-html nodes
          css('.katex-html').remove
        end
        doc
      end
    end
  end
end
