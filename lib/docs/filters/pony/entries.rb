module Docs
  class Pony
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        binding.pry
        context[:html_title].sub(/ - .*/, '')
      end

      def get_type
        subpath.split('-')[0][1..-1]
      end
    end
  end
end
