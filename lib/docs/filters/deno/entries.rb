module Docs
  class Deno
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        at_css('h1').content
      end

      def get_type
        'Deno CLI APIs'
      end

    end
  end
end
