module Docs
  class Underscore
    class CleanHtmlFilter < Filter
      def call
        # Remove Links, Changelog
        css('#links ~ *', '#links').remove

        doc
      end
    end
  end
end
