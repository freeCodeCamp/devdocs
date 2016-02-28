module Docs
  class Influxdata
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('#page-title h1').content
      end

      def get_type
        product = at_css('.product-switcher--current').content.strip
        return product if %w(Chronograf Telegraf).include?(product)

        node = at_css('#product-sidebar a[href="index"]')
        node = node.parent.previous_element unless node.parent['class'] == 'product-sidebar--section-title'

        type = node.content.strip
        type.remove! ' Reference'

        if type.in?(%w(Getting\ Started Introduction Guides))
          product
        else
          "#{product}: #{type}"
        end
      end

      def include_default_entry?
        !subpath.end_with?("v#{Influxdata.release}/")
      end
    end
  end
end
