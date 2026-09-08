module Docs
  class Deno
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('main#content article', 'article') || doc

        css('.breadcrumbs', '.copy-page-split', '.copyButton',
            '.docNodeKindIcon', '.header-anchor', 'a > svg',
            'nav[aria-label="Breadcrumb"]',
            'nav[aria-label="Previous and next page"]').remove

        css('details > summary').each do |node|
          node.parent.remove if node.content.strip == 'On this page'
        end

        css('h1, h2, h3, h4, h5, h6').each do |node|
          node.css('a.anchor[aria-label="Anchor"]').remove
        end

        css('pre > code').each do |node|
          language = node['class'].to_s[/\blanguage-([\w-]+)/, 1]
          node.parent['data-language'] = language if language
        end

        doc
      end
    end
  end
end
