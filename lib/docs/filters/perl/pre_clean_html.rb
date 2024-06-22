module Docs
  class Perl
    class PreCleanHtmlFilter < Filter
      def call
        css('#links', '.leading-notice', '.permalink').remove

        # Bug somewhere prevents these two ids from loading
        if slug == 'perlvar'
          at_css('#\$\"')['id'] = '$ls'
          at_css('#\$\#')['id'] = '$hash'
        end

        doc
      end
    end
  end
end
