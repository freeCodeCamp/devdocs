module Docs
  class Tailwindcss
    class CleanHtmlFilter < Filter
      def call
        css('div.sticky.top-0').remove
        css('.sr-only').remove
        css('#sidebar').remove

        css('#nav ul li').each do |node|
          link = node.css("a").attr('href').to_s
          if link.include? "https://"
            node.remove()
          end
        end
        doc
      end
    end
  end
end
