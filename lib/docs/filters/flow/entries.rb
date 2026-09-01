module Docs
  class Flow
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        css('.breadcrumbs__item .breadcrumbs__link')[-2]&.content&.strip.presence || get_name
      end
    end
  end
end
