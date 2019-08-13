module Docs
  class VueRouter
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.content')

        # Remove unneeded elements
        css('.bit-sponsor, .header-anchor').remove

        doc
      end
    end
  end
end
