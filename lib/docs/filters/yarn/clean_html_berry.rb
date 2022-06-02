module Docs
  class Yarn
    class CleanHtmlBerryFilter < Filter
      def call
        if slug.empty?
          @doc = at_css('main')
          css(
            (['div:first-child'] * 3).join('>'), # Tagline
            'img',
            'hr', # Footer
            'hr + div', # Footer
          ).remove

          css('a').each do |link|
            link.name = 'div'
            link.css('h3').each do |node|
              node.replace("<h2><a href='#{link['href']}'>#{node.content}</a></h2>")
            end
          end

          return doc
        end

        @doc = at_css('article')
        # Heading & edit link
        css('h1', 'h1 + a').remove unless slug.start_with?('configuration')

        if slug.start_with?('cli')
          css('.header-code').each do |node|
            node.name = 'span'
          end
        end

        if slug.start_with?('configuration')
          css('h1', 'h2').each do |node|
            node.name = node.name.sub(/\d/) { |i| i.to_i + 1 }
          end
        end

        css('*').each do |node|
          node.remove_attribute('style')
        end

        doc
      end
    end
  end
end
