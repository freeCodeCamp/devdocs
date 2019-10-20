module Docs
  class Reactivex
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        title = at_css('h1').content
        title = title.titleize if is_backpressure_operators?
        title
      end

      def get_type
        return 'Manual' if is_backpressure_operators?
        links = css('.breadcrumb > li:nth-child(2) > a')
        links.size > 0 ? links.first.content : 'Manual'
      end

      def is_backpressure_operators?
        subpath == 'documentation/operators/backpressure.html'
      end
    end
  end
end
