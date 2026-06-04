module Docs
  class Odin
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#pkg') || doc

        css('nav').remove
        doc
      end
    end
  end
end
