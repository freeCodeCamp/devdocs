module Docs
  class Pandas
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.body')

        doc
      end
    end
  end
end
