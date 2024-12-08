module Docs
  class React
    class EntriesReactDevFilter < Docs::EntriesFilter
      def get_name
        name = at_css('article h1').content
        return update_canary_copy(name)
      end

      def get_type
        breadcrumb_nodes = css('a.tracking-wide')
        is_top_level_page = breadcrumb_nodes.length == 1
        category = if is_top_level_page
          # Category is the opened category in the sidebar
          css('aside a.text-link div').first.content
        else
          breadcrumb_nodes.last.content
        end
        is_learn_page = path.start_with?('learn/')
        prefix = is_learn_page ? 'Learn: ' : ''
        return update_canary_copy(prefix + (category || 'Miscellaneous'))
      end

      def update_canary_copy(string)
        canary_copy = '- This feature is available in the latest Canary'
        return string.sub(canary_copy, ' (Canary)')
      end
    end
  end
end
