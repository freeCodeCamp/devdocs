module Docs
  class Dojo
    class CleanHtmlFilter < Filter
      def call
        # TODO: Probably needs a little more cleanup but should do for the moment
        css('script').remove
        doc
      end
    end
  end
end
