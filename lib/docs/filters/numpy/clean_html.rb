module Docs
  class Numpy
    class CleanHtmlFilter < Filter
      def call
        at_css('#spc-section-body, main > div')
      end
    end
  end
end
