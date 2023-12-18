module Docs
  class Bazel
    class CleanHtmlFilter < Filter

      def call
        css('.devsite-article-meta').remove
        css('devsite-feature-tooltip').remove
        css('devsite-thumb-rating').remove
        css('devsite-toc').remove
        css('a.button-with-icon').remove
        css('button.devsite-heading-link').remove
        doc
      end

    end
  end
end
