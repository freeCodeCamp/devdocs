module Docs
  class Yarn
    class EntriesBerryFilter < Docs::EntriesFilter
      def get_name
        at_css('main header h1').content
      end

      def get_type
        at_css('nav.navbar a.navbar__item.navbar__link.navbar__link--active').content
      end
    end
  end
end
