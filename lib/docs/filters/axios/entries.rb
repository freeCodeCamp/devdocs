module Docs
  class Axios
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        'axios'
      end
    end
  end
end
