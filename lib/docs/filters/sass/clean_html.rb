module Docs
  class Sass
    class CleanHtmlFilter < Filter
      def call
        css('tt').each do |node|
          node.name = 'code'
        end

        css('pre').each do |node|
          node.content = node.content
        end

        root_page? ? root : other

        doc
      end

      def root
        at_css('h1 + ul').remove
      end

      def other
        at_css('h2').remove

        css('.showSource', '.source_code').remove

        css('div.docstring', 'div.discussion').each do |node|
          node.before(node.children).remove
        end

        # Remove "See Also"
        css('.see').each do |node|
          node.previous_element.remove
          node.remove
        end

        # Remove "- ([...])" before method names
        css('.signature', 'span.overload', 'span.signature').each do |node|
          next if node.at_css('.overload')
          node.child.remove while node.child.name != 'strong'
        end

        # Clean up .inline divs
        css('div.inline').each do |node|
          node.content = node.content
          node.name = 'span'
        end

        # Remove links to type classes (e.g. Number)
        css('.type > code').each do |node|
          node.before(node.content.remove('Sass::Script::Value::').remove('Sass::Script::')).remove
        end

        css('li > span.signature').each do |node|
          node.name = 'p'
        end

        css('h3 strong', 'span.overload').each do |node|
          node.before(node.children).remove
        end
      end
    end
  end
end
