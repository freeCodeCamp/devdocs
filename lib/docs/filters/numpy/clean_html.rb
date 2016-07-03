module Docs
  class Numpy
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#spc-section-body')

        doc
      end
    end
  end
end
