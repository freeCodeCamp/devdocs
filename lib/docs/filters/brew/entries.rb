module Docs
  class Brew
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        name
      end

    end
  end
end
