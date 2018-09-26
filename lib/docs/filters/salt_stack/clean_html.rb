module Docs
  class SaltStack
    class CleanHtmlFilter < Filter
      def call
        css('.headerlink').remove

        doc
      end
    end
  end
end
