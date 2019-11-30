module Docs
  class WebExtensions
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('main#content h1').text
      end

      def get_type
        slug_parts = slug.split('/')
        if slug_parts[0] == 'API' and slug_parts.length() > 1
          if slug_parts[1] == 'WebRequest'
            return 'webRequest'
          else
            return slug_parts[1]
          end
        elsif slug_parts[0] == 'manifest.json'
          return slug_parts[0]
        elsif slug_parts[0] == 'user_interface'
          return 'User Interface'
        elsif slug_parts.length() > 1
          return slug_parts[0]
        else
          return 'Miscellaneous'
        end
      end
    end
  end
end
