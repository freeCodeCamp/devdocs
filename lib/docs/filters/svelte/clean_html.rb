module Docs
  class Svelte
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('main .page.content')
        at_css('h1').content = 'Svelte' if root_page?
        css('pre').each do |node|
          node.content = node.css('.line').map(&:content).join("\n")
          node['data-language'] = 'javascript'
        end
        doc
      end
    end
  end
end
