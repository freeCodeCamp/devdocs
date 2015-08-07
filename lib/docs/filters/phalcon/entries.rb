module Docs
  class Phalcon
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        node = css('h1').first
        name = node.content.strip
        node.remove
        name
      end

      def get_type
        if slug.start_with?('reference')
          'Reference'
        else
          'API'
        end
      end
    end
  end
end
