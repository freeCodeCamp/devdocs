module Docs
  class React
    class CleanHtmlReactDevFilter < Filter
      def call
        @doc = at_css('article')

        doc
      end
    end
  end
end
