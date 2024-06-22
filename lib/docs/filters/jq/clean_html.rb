module Docs
  class Jq
    class CleanHtmlFilter < Filter
      def call
        css('.manual-example').each do |node|
          container = node.parent
          example_header = doc.document.create_element('h4')
          example_header.content = container.at_css('a[data-toggle="collapse"]').content
          node.children.before(example_header)

          node.remove_class('collapse')
          container.replace(node)
        end
        doc
      end
    end
  end
end
