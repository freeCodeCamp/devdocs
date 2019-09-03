module Docs
  class Numpy
    class CleanHtmlFilter < Filter
      def call
        at_css('#spc-section-body')
      end
    end
  end
end
