module Docs
  class React
    class EntriesReactDevFilter < Docs::EntriesFilter
      def get_name
        canary_copy = '- This feature is available in the latest Canary'
        name = at_css('article h1').content
        return name.sub(canary_copy, ' (Experimental)')
      end

      def get_type
        breadcrumb_nodes = css('a.tracking-wide')
        return breadcrumb_nodes.last.content || 'Miscellaneous'
      end
    end
  end
end
