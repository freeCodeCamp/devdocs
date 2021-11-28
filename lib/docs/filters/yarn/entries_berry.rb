module Docs
  class Yarn
    class EntriesBerryFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content

        name
      end

      def get_type
        if slug.start_with?('sdks') || slug.start_with?('pnpify')
          'CLI'
        else
          type = at_css('header div:nth-child(2) .active').content.strip
          type.remove! 'Home'
          type
        end
      end
    end
  end
end
