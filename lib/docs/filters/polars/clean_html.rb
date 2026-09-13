module Docs
  class Polars
    class CleanHtmlFilter < Filter
      def call
        # Remove pydata-sphinx-theme chrome that survives the container extraction
        # or sits inside the article (sidebars, in-page TOC, prev/next nav, footer).
        css(
          '.bd-sidebar-primary',
          '.bd-sidebar-secondary',
          '.bd-toc',
          '.bd-header-article',
          '.prev-next-area',
          '.prev-next-footer',
          '.bd-footer',
          '.headerlink',
          'form'
        ).remove

        # Drop banner/logo imagery on the landing page.
        css('img').remove if root_page?

        # Make sure every code block is tagged so Prism highlights it as Python.
        css('.highlight pre').each do |node|
          node.content = node.content
          node['data-language'] = 'python'
        end

        doc
      end
    end
  end
end
