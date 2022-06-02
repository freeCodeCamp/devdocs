module Docs
  class PointCloudLibrary
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.contents')
        css('.dynheader.closed').remove
        css('.permalink').remove
        doc
      end
    end
  end
end
