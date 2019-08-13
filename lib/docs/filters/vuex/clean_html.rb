module Docs
  class Vuex
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.content')

        # Remove video from root page
        css('a[href="#"]').remove if root_page?

        # Remove unneeded elements
        css('.header-anchor').remove

        doc
      end
    end
  end
end
