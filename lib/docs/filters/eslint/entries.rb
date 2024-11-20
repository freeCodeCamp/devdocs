module Docs
  class Eslint
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name
      end

      def get_type
        if subpath.start_with?('rules')
          return 'Rules'
        else
          type = at_css('nav.docs-index [aria-current="true"]').ancestors('li')[-1].at_css('a').content
          # This specific entry is mispelled with a lowercase 'i'
          if type.start_with?('integrate')
            type = type.sub('integrate', 'Integrate')
          end
          return type
        end
      end
    end
  end
end
