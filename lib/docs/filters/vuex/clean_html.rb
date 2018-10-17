module Docs
  class Vuex
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.content')

        # Remove unneeded elements
        css('.header-anchor').remove

        doc
      end
    end
  end
end