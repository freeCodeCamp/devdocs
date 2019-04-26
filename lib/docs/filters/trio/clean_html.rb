module Docs
  class Trio
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('div[role="main"]')
        css('.section, [itemprop=articleBody]').each do |node|
          node.replace node.children
        end

        css('.headerlink').remove

        css('dt').each do |node|
          new_node = doc.document.create_element "h3"
          new_node.content = node.inner_text[0...-1]
          node.replace new_node
        end
        doc
      end
    end
  end
end
