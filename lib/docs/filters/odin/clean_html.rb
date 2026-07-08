module Docs
  class Odin
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#pkg') || doc

        css('nav').remove
        css('.pkg-breadcrumb').remove
        css('.a-hidden').remove
        css('.doc-source').remove
        css('.odin-search-wrapper').remove
        css('#pkg-sidebar').remove
        css('#odin-search-info').remove
        css('#odin-search-results').remove
        css('.pkg-index').remove
        css('h2 .text-decoration-none').remove
        css('h3 .text-decoration-none').remove

        doc
      end
    end
  end
end
