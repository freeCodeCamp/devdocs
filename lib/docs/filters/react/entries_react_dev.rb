module Docs
  class React
    class EntriesReactDevFilter < Docs::EntriesFilter
      def get_name
        at_css('article h1').content
      end

      def get_type
        return 'TODO add types'
      end
    end
  end
end
