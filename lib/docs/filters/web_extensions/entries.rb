module Docs
  class WebExtensions
    class EntriesFilter < Docs::EntriesFilter
      TYPE_BY_PATH = {
        'manifest.json' => 'manifest.json',
        'user_interface' => 'User Interface',
        'WebRequest' => 'webRequest',
      }

      def get_name
        at_css('h1').text
      end

      def get_type
        slug_parts = slug.split('/')
        if slug_parts[0] == 'API' and slug_parts.length() > 1
          return TYPE_BY_PATH.fetch(slug_parts[1], slug_parts[1])
        else
          return TYPE_BY_PATH.fetch(slug_parts[0], slug_parts.length() > 1 ? slug_parts[0] : 'Miscellaneous')
        end
      end
    end
  end
end
