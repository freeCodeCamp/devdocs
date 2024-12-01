module Docs
  class React
    class CleanHtmlReactDevFilter < Filter
      def call
        @doc = at_css('article')

        # Remove breadcrumbs before h1
        css('h1').each do |node|
          if (node.previous)
            node.previous.remove
          end
        end

        remove_selectors = [
          'div.grid > a', # prev-next links
           'button', # "show more" etc. buttons
           'div.order-last', # code iframe containers
           'a[title="Open in CodeSandbox"]', # codesandbox links
        ]
        css(*remove_selectors).each do |node|
          node.remove
        end

        # Remove recipe blocks - TODO transform to outgoing link to docs
        css('h4[id^="examples-"]').each do |node|
          node.parent.parent.parent.remove
        end

        # Remove styling divs while lifting children
        styling_prefixes = [
          'ps-', 'mx-', 'my-', 'px-', 'py-', 'mb-', 'sp-', 'rounded-'
        ]
        selectors = styling_prefixes.map { |prefix| "div[class*=\"#{prefix}\"]" }
        css(*selectors, 'div[class=""]', 'div.cm-line').each do |node|
          node.before(node.children).remove
        end

        # Syntax highlighting
        css('pre br').each do |node|
          node.replace("\n")
        end
        css('pre').each do |node|
          node['data-language'] = 'jsx'
        end

        doc
      end
    end
  end
end
