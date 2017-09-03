module Docs
  class Influxdata
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('.article-heading h1').content
        name.remove! %r{\s\(.+\)}
        name
      end

      def get_type
        product = at_css('.navbar--current-product').content.split(' ').first.capitalize.sub('db', 'DB')
        return product if %w(Chronograf Telegraf).include?(product)
        return "#{product}: Tools" if subpath.include?('tools/')

        node = at_css('a.sidebar--page[href="index"]')
        node ||= at_css('.sidebar--section-title a[href="index"]').parent
        node = node.previous_element until node['class'] == 'sidebar--section-title'

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
