module Docs
  class SaltStack
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        'TODO'
      end
    end
  end
end
