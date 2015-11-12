module Docs
  class Dojo
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        name
      end
      # TODO:Figure out how to solve the internal links issue later
    end
  end
end