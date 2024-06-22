module Docs
  class Godot
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          at_css('h1').content = 'Godot Engine'
          at_css('.admonition.note').remove
        end

        css('ul[id].simple li:first-child:last-child').each do |node|
          heading = Nokogiri::XML::Node.new 'h3', doc.document
          heading['id'] = node.parent['id']
          heading.children = node.children
          node.parent.before(heading).remove
        end

        css('h3 strong').each do |node|
          node.before(node.children).remove
        end

        css('a.reference').remove_attr('class')

        doc
      end
    end
  end
end
