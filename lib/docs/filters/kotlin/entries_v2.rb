module Docs
  class Kotlin
    class EntriesV2Filter < Docs::EntriesFilter
      def get_name
        if api?
          return breadcrumbs[1..].join('.') if breadcrumbs.length > 1
        else
          node = at_css('h1') || at_css('h2')
          return [breadcrumbs[1..], node.content.squish].flatten.join(': ') unless node.nil?
        end
        super
      end

      def get_type
        if api?
          breadcrumbs.length > 1 ? breadcrumbs[1] : 'Overview'
        else
          # The top-level guides ("Get started", …) carry no breadcrumbs of their own.
          breadcrumbs[0].presence || 'Guides'
        end
      end

      private

      def api?
        subpath.start_with?('api/')
      end

      def breadcrumbs
        @breadcrumbs ||= if api?
          # Dokka 2 renders a list of links followed by a <span class="current">
          # for the page itself, separated by delimiters.
          css('.breadcrumbs > *:not(.delimiter)').map { |node| node.content.strip }
        else
          doc.document.at_css('body')&.attr('data-breadcrumbs').to_s.split('///')
        end
      end
    end
  end
end
