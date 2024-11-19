module Docs
  class Svelte
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('main .page.content #docs-content')

        # Remove title header
        at_css('> header > div.breadcrumbs').remove()
        # Remove extra input toggle
        at_css('> aside.on-this-page input').remove()
        # Remove "edit this page" link
        at_css('> p.edit').remove()
        # Remove footer navigation
        at_css('> div.controls').remove()

        at_css('h1').content = 'Svelte' if root_page?
        css('pre').each do |node|
          # Remove hover popup
          node.css('.twoslash-popup-container').remove()
          node.content = node.css('.line').map(&:content).join("\n")
          node['data-language'] = 'typescript'
        end
        doc
      end
    end
  end
end
