module Docs
  class React
    class EntriesReactDevFilter < Docs::EntriesFilter
      def get_name
        name = at_css('article h1')&.content

        update_canary_copy(name)
      end

      def get_type
        # Category is the opened category in the sidebar
        category = css('a:has(> span.text-link) > div').first&.content
        # The grey category in the sidebar
        top_category = css('h3:has(~ li a.text-link)')
                         .last&.content
                         &.sub(/@.*$/, '') # remove version tag
                         &.sub(/^./, &:upcase) # capitalize first letter
                         &.concat(": ")
        is_learn_page = path.start_with?('learn/') || slug == 'learn'
        prefix = is_learn_page ? 'Learn: ' : top_category || ''

        update_canary_copy(prefix + (category || 'Miscellaneous'))
      end

      def update_canary_copy(string)
        canary_copy = '- This feature is available in the latest Canary'

        string.sub(canary_copy, ' (Canary)')
      end
    end
  end
end
