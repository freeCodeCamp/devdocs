module Docs
  class React
    class CleanHtmlReactDevFilter < Filter
      def call
        @doc = at_css('article')

        # Remove breadcrumbs before h1
        css('h1').each do |node|
          if node.previous
            node.previous.remove
          end
        end

        remove_selectors = [
          'div.grid > a', # prev-next links
          'button', # "show more" etc. buttons
          'div.order-last', # code iframe containers
          'div.dark-image', # dark images
          'a[title="Open in CodeSandbox"]', # codesandbox links
        ]
        css(*remove_selectors).each do |node|
          node.remove
        end

        # Fix images not loading
        css('img').remove_attr('srcset')

        # Remove recipe blocks - TODO transform to outgoing link to docs
        css('h4[id^="examples-"]').each do |node|
          node.parent.parent.parent.remove
        end

        # Transform callout blocks
        class_transform = {
          '.expandable-callout[class*=yellow]' => 'note note-orange', # pitfalls, experimental
          '.expandable-callout[class*=green]' => 'note note-green', # note
          '.expandable-callout[class*=gray]' => 'note', # canary
          '.bg-card' => 'note', # you will learn
          'details' => 'note note-blue' # deep dive
        }

        class_transform.each do |old_class, new_class|
          css(old_class).each do |node|
            node.set_attribute('class', new_class)
          end
        end

        # Transform h3 to h4 inside callouts
        css('.note h3', '.note h2').each do |node|
          new_node = Nokogiri::XML::Node.new('h4', @doc)
          new_node.content = node.content
          node.replace(new_node)
        end

        # Remove styling divs while lifting children
        styling_prefixes = %w[ps- mx- my- px- py- mb- sp- rounded-]
        selectors = styling_prefixes.map { |prefix| "div[class*=\"#{prefix}\"]:not(.note)" }
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

        # Remove styling except for callouts and images
        css('*:not([class*=image]):not(.note)').remove_attr('class').remove_attr('style')

        doc
      end
    end
  end
end
