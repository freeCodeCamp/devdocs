module Docs
  class Angular
    class CleanHtmlV18Filter < Filter
      def call
        @doc = at_css('.docs-viewer') if at_css('.docs-viewer')

        # Extract <h1> from decorative header.
        @doc.prepend_child(at_css('h1'))
        css('h1[class]').remove_attr('class')

        css(
          '.docs-breadcrumb',
          '.docs-github-links',
          'docs-table-of-contents',
          '.docs-reference-category',
          '.docs-reference-title',
          '#jump-msg'
        ).remove

        # Strip anchor links from headers.
        css('h2', 'h3', 'h4').each do |node|
          node.content = node.inner_text
        end

        # Make every <code> block a <pre>.
        css('.docs-code > pre > code').each do |code|
          code.name = 'pre'
          code['data-language'] = 'ts'
          code.content = code.css('.line').map(&:content).join("\n")
          code.parent.parent.replace(code)
        end

        # Better format content in CLI reference.
        css('.docs-ref-content').each do |ref|
          option = ref.at_css('.docs-reference-option code')
          option.name = 'h3'
          option.parent.replace(option)
        end

        css('.docs-reference-type-and-default', '.docs-reference-option-aliases').each do |node|
          labels = node.css('span')
          values = node.css('code')
          labels.each do |l|
            l.name = 'h4'
          end
        end

        css('footer').remove

        doc
      end
    end
  end
end
