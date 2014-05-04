module Docs
  class Maxcdn
    class CleanHtmlFilter < Filter
      def call
        css('hr', 'td:last-child:empty').remove

        css('h1, h2, h3, h4').each do |node|
          node.name = node.name.sub(/\d/) { |i| i.to_i + 1 }
        end

        at_css('h2').name = 'h1'

        css('.path > a').each do |node|
          node.before(node.children).remove
        end

        css('[name]').each do |node|
          node.remove_attribute 'name'
        end

        doc
      end
    end
  end
end
