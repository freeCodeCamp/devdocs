module Docs
  class Yarn
    class EntriesBerryFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content

        # TODO: remove when https://github.com/yarnpkg/berry/issues/3809 is resolved
        if slug.start_with?('sdks') || slug.start_with?('pnpify')
          name.prepend('yarn ')
        end

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
