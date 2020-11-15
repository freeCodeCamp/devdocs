module Docs
  class Fish
    class CleanHtmlSphinxFilter < Filter
      def call
        @doc = at_css('.body')
        doc
      end
    end
  end
end
