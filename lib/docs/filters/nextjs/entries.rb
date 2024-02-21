module Docs
  class Nextjs
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content
        name.strip!
        name
      end

      def get_type
        if subpath.include?('/architecture')
          'Architecture'
        elsif subpath.include?('/community')
          'Community'
        elsif subpath.include?('/getting-started')
          'Getting Started'
        elsif subpath.include?('/messages')
          'Messages'
        elsif subpath.include?('/app')
          'Using App Router'
        elsif subpath.include?('/pages')
          'Using Pages Router'
        else
          get_name
        end
      end
    end
  end
end
