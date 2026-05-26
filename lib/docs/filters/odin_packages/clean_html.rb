module Docs
  class OdinPackages
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#pkg') || doc

        css('.pkg-breadcrumb').remove
        css('.a-hidden').remove
        css('.doc-source').remove
        css('.odin-search-wrapper').remove
        css('#pkg-sidebar').remove
        css('#odin-search-info').remove
        css('#odin-search-results').remove

        doc
      end
    end
  end
end
