module Docs
  class React
    class EntriesReactDevFilter < Docs::EntriesFilter
      def get_name
        canary_copy = '- This feature is available in the latest Canary'
        name = at_css('article h1').content
        return name.sub(canary_copy, ' (Canary)')
      end

      def get_type
        breadcrumb_nodes = css('a.tracking-wide')
        category = breadcrumb_nodes.last.content
        is_learn_page = base_url.to_s.end_with?('learn')
        prefix = is_learn_page ? 'Learn: ' : ''
        return prefix + (category || 'Miscellaneous')
      end
    end
  end
end
