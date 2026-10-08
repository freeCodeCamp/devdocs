module Docs
  class Pytorch
    class CleanHtmlFilter < Filter
      def call
        if root = at_css('#pytorch-article')
          @doc = root
        end
        doc
      end
    end
  end
end
