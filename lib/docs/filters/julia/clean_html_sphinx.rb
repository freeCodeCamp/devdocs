module Docs
  class Julia
    class CleanHtmlSphinxFilter < Filter
      def call
        @doc = at_css('.document .section')

        doc
      end
    end
  end
end
