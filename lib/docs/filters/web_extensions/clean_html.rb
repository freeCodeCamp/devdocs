module Docs
  class WebExtensions
    class CleanHtmlFilter < Filter
      def call

        # Remove all the cruft.
        content = at_css('main#content')
        content.at_css('aside.metadata').remove

        content
      end
    end
  end
end
