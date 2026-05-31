module Docs
  class Powershell
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content.strip
      end

      def get_type
        parts = slug.split('/')
        parts.length > 1 ? parts.first : 'Overview'
      end
    end
  end
end
