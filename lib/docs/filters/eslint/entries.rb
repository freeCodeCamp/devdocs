module Docs
  class Eslint
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        if subpath.start_with?('docs/developer-guide/')
          type = 'Developer Guide'
        elsif subpath.start_with?('docs/user-guide/')
          type = 'User Guide'
        elsif subpath.start_with?('docs/rules')
          type = 'Rules'
        elsif subpath.start_with?('docs/about')
          type = 'User Guide'
        else
          type = nil
        end
        type
      end
      
    end
  end
end
