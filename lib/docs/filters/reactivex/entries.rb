module Docs
  class Reactivex
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        links = css('.breadcrumb > li:nth-child(2) > a')
        links.size > 0 ? links.first.content : 'Manual'
      end
    end
  end
end
