module Docs
  class Sass
    class CleanHtmlFilter < Filter
      def call
        css('tt').each do |node|
          node.name = 'code'
        end

        root_page? ? root : other

        doc
      end

      def root
        at_css('.maruku_toc').remove
      end

      def other
        at_css('h2').remove

        css('.showSource', '.source_code').remove

        # Remove "See Also"
        css('.see').each do |node|
          node.previous_element.remove
          node.remove
        end

        # Un-indent code blocks
        css('pre.example').each do |node|
          node.inner_html = node.inner_html.strip_heredoc
        end

        # Remove "- " before method names
        css('.signature', 'span.overload').each do |node|
          node.child.content = node.child.content.sub(/\A\s*-\s*/, '')
        end

        # Remove links to type classes (e.g. Number)
        css('.type > code > a, .signature > code > a, span.overload > code > a').each do |node|
          node.before(node.content)
          node.remove
        end
      end
    end
  end
end
