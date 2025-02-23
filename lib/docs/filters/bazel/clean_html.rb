module Docs
  class Bazel
    class CleanHtmlFilter < Filter

      def call
        css('.devsite-article-meta').remove
        css('devsite-feature-tooltip').remove
        css('devsite-thumb-rating').remove
        css('devsite-toc').remove
        css('devsite-feedback').remove
        css('a.button-with-icon').remove
        css('button.devsite-heading-link').remove
        css('.devsite-article-body > span:first-child[style="float: right; line-height: 36px"]').remove
        doc
      end

    end
  end
end
