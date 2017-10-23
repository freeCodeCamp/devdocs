module Docs
  class Eslint
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.doc') if at_css('.doc')
        doc
      end
    end
  end
end
