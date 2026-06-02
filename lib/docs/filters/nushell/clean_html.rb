module Docs

  class Nushell
    class CleanHtmlFilter < Filter
      def call
        css('footer').remove

        css('span.lang').remove

        css('h1 > a').each do |node|
          node.before(node.children).remove
        end
        
        css('pre > code:first-child').each do |node|
          node.parent['data-language'] = 'sh'
          node.parent.content = node.css('.line').map(&:content).join("\n")
        end

        doc
      end
    end
  end

end
