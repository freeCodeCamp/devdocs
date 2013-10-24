module Docs
  class Less
    class CleanHtmlFilter < Filter
      def call
        # Remove everything but language and function reference
        doc.children = css('#docs', '#reference').children

        # Change headings
        css('h1', 'h2', 'h3').each do |node|
          node.name = "h#{node.name.last.to_i + 1}"
          node['id'] ||= node.content.strip.parameterize
        end

        # Remove .content div
        css('.content').each do |node|
          node.before(node.elements)
          node.remove
        end

        # Remove function index
        css('#function-reference').each do |node|
          while node.next.content.strip != 'String functions'
            node.next.remove
          end
        end

        # Remove duplicates
        [css('[id="unit"]').last, css('[id="color"]').last].each do |node|
          node.next.remove while %w(h2 h3 h4).exclude?(node.next.name)
          node.remove
        end

        # Differentiate function headings
        css('#function-reference ~ h4').each do |node|
          node['class'] = 'function'
        end

        doc
      end
    end
  end
end
