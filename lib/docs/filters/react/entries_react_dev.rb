module Docs
  class React
    class EntriesReactDevFilter < Docs::EntriesFilter
      def get_name
        canary_copy = '- This feature is available in the latest Canary'
        name = at_css('article h1').content
        return name.sub(canary_copy, ' (experimental)')
      end

      def get_type
        return 'TODO add types'
      end
    end
  end
end
