module Docs
  class Padrino
    class CleanHtmlFilter < Filter
      def call
        css('.summary_toggle').remove
        css('.inheritanceTree').remove
        at_css('#content')
      end
    end
  end
end
