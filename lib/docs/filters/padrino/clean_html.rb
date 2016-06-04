module Docs
  class Padrino
    class CleanHtmlFilter < Filter
      def call
        at_css('#content')
      end
    end
  end
end
