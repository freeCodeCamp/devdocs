module Docs
  class Opentsdb
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('.section > h1').content
      end

      def get_type
        if subpath.start_with?('api_http')
          'HTTP API'
        elsif slug.end_with?('/index')
          [breadcrumbs[1], name].compact.join(': ')
        elsif breadcrumbs.length < 2
          'Miscellaneous'
        else
          breadcrumbs[1..2].join(': ')
        end
      end

      def breadcrumbs
        @breakcrumbs ||= at_css('.related').css('li:not(.right) a').map(&:content).reject(&:blank?)
      end
    end
  end
end
