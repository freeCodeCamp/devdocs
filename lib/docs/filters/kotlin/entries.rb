module Docs
  class Kotlin
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if at_css('h1')
          name = at_css('h1').text
          module_name = breadcrumbs[1]

          "#{module_name}.#{name}"
        elsif at_css('h2')
          at_css('h2').text.gsub 'Package ', ''
        elsif at_css('h3')
          at_css('h3').text
        end
      end

      def get_type
        if package? || top_level? && !extensions?
          breadcrumbs[1]
        else
          "miscellaneous"
        end
      end

      private

      def breadcrumbs
        container = at_css('.api-docs-breadcrumbs')

        if container
          links = container.children.select.with_index { |_, i| i.even? }
          links.map &:text
        else
          []
        end
      end

      def top_level?
        breadcrumbs.size == 3
      end

      def extensions?
        get_name.start_with? 'Extensions'
      end

      def package?
        breadcrumbs.size == 2
      end
    end
  end
end
