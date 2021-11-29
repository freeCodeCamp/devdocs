module Docs
  class Yarn
    class EntriesBerryFilter < Docs::EntriesFilter
      def get_name
        if slug.start_with?('configuration')
          filename = at_css('main .active code')
          content = filename.content
          return filename.parent.content.sub content, " (#{content})"
        end

        name = at_css('h1').content

        if slug.start_with?('getting-started')
          name.remove! /\d - /

          active_link = at_css('main .active')
          links = active_link.parent.children.to_a
          name.prepend "#{links.index(active_link) + 1}. "
        end

        # TODO: remove when https://github.com/yarnpkg/berry/issues/3809 is resolved
        name.prepend('yarn ') if slug.start_with?('sdks', 'pnpify')

        name
      end

      def get_type
         return 'CLI' if slug.start_with?('sdks', 'pnpify')
         at_css('header .active').content
      end
    end
  end
end
