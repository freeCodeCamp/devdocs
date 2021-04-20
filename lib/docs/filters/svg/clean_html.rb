module Docs
  class Svg
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root

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

        if at_css('#browser_compatibility') \
          and not at_css('#browser_compatibility').next_sibling.classes.include?('warning') \
          and not at_css('#browser_compatibility').next_sibling.content.match?('Supported')

          at_css('#browser_compatibility').next_sibling.remove

          compatibility_tables = generate_compatibility_table()
          compatibility_tables.each do |table|
            at_css('#browser_compatibility').add_next_sibling(table)
          end
        end
      end

    end
  end
end
