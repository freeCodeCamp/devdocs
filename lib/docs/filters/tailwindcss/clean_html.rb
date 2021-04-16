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

        # Remove right sidebar
        css('#content-wrapper > div > div.hidden.xl\:text-sm.xl\:block.flex-none.w-64.pl-8.mr-8 > div > div').each do |node|
          node.remove
        end

        # Remove advert
        css('#__next > div.py-2.bg-gradient-to-r.from-indigo-600.to-light-blue-500.overflow-hidden').each do |node|
          node.remove
        end

        # Remove footer prev/next navigation
        css('#content-wrapper > div > div > div.flex.leading-6.font-medium').each do |node|
          node.remove
        end

        doc

      end
    end
  end
end
