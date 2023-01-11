module Docs
  class Eslint
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name
      end

      def get_type
        if subpath.include?('developer-guide')
          'Developer Guide'
        elsif subpath.include?('guide')
          'Guide'
        elsif subpath.start_with?('rules')
          'Rules'
        end
      end
    end
  end
end
