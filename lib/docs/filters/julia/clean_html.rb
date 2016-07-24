module Docs
  class Julia
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.document .section')

        doc
      end
    end
  end
end
