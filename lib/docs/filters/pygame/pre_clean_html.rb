module Docs
  class Pygame
    class PreCleanHtmlFilter < Filter
      def call
        # Remove ¶ character from tag w/ name & type
        css('.headerlink').remove
        doc
      end
    end
  end
end
