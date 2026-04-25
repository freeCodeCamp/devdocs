module Docs
  class Deno
    class EntriesFilter < Docs::EntriesFilter
      TYPES_BY_PATH = {
        'api'     => 'API',
        'runtime' => 'Runtime',
      }

      def get_name
        name = at_css('h1')
        name ? name.content.strip : slug.split('/').last
      end

      def get_type
        TYPES_BY_PATH[slug.split('/').first] || 'Guide'
      end
    end
  end
end
