module Docs
  class Kotlin
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if subpath.start_with?('api')
          breadcrumbs[1..-1].join('.')
        else
          node = (at_css('h1') || at_css('h2'))
          return [breadcrumbs[1..], [node.content]].flatten.join(': ') unless node.nil?
        end
      end

      def get_type
        if subpath.start_with?('api')
          breadcrumbs[1]
        else
          breadcrumbs[0]
        end
      end

      private

      def breadcrumbs
        if subpath.start_with?('api')
          @breadcrumbs ||= css('.api-docs-breadcrumbs a').map(&:content).map(&:strip)
        else
          @breadcrumbs ||= doc.document.at_css('body')['data-breadcrumbs'].split('///')
        end 
      end
    end
  end
end
