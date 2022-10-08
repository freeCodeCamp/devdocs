module Docs
  class Nuxtjs
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        header = at_css('h1')
        if header
          header.content
        else
          path.split("/").last.titleize
        end
      end

      def get_type
        path.split("/").first.titleize
      end
    end
  end
end
