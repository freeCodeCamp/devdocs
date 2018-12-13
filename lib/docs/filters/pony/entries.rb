module Docs
  class Pony
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        context[:html_title].sub(/ - .*/, '')
      end

      def get_type
        subpath.split('-')[0][0..-1]
      end
    end
  end
end
