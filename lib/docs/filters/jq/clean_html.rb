module Docs
  class Jq
    class CleanHtmlFilter < Filter
      def call
        content = at_css('div#manualcontent')

        css('.manual-example').each do |node|
          container = node.parent
          example_header = doc.document.create_element('h4')
          example_header.content = container.at_css('a[data-toggle="collapse"]').content
          node.children.before(example_header)

          node.remove_class('collapse')
          container.replace(node)
        end

        content
      end
    end
  end
end
