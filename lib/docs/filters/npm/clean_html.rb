module Docs
  class Npm
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('main')

        css('details').remove
        css('nav[aria-label="Breadcrumbs"]').remove
        css('.gtWOdv').remove  # Select CLI Version
        css('.ezMiXD').remove  # Navbox
        css('.gOhcvK').remove  # Edit this page on GitHub

        css('pre').each do |node|
          node.content = node.css('.token-line').map(&:content).join("\n")
          node['data-language'] = 'javascript'
        end

        doc
      end
    end
  end
end
