module Docs
  class Django
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.yui-g')

        doc
      end
    end
  end
end
