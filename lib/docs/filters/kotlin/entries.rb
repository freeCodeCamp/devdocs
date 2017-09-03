module Docs
  class Kotlin
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if subpath.start_with?('api')
          breadcrumbs[1..-1].join('.')
        else
          (at_css('h1') || at_css('h2')).content
        end
      end

      def get_type
        if subpath.start_with?('api')
          breadcrumbs[1]
        elsif subpath.start_with?('docs/tutorials')
          'Tutorials'
        elsif subpath.start_with?('docs/reference')
          'Reference'
        end
      end

      private

      def breadcrumbs
        @breadcrumbs ||= css('.api-docs-breadcrumbs a').map(&:content).map(&:strip)
      end
    end
  end
end
