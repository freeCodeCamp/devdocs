module Docs
  class Pytorch
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.pytorch-article')
        # Show katex-mathml nodes and remove katex-html nodes
        css('.katex-html').remove
        doc
      end
    end
  end
end
