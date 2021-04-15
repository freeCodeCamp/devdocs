module Docs
  class Svg
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
        doc.inner_html = doc.at_css('#Documentation + dl').to_html
      end

      def other
        css('.prev-next').remove

        if at_css('p').content.include?("\u{00AB}")
          at_css('p').remove
        end

        if slug == 'Attribute' || slug == 'Element'
          at_css('h2').name = 'h1'
        end

        css('#SVG_Attributes + div[style]').each do |node|
          node.remove_attribute('style')
          node['class'] = 'index'
          css('h3').each { |n| n.name = 'span' }
        end
      end
    end
  end
end
