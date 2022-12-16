# frozen_string_literal: true

module Docs
  class Qunit
    class EntriesFilter < Docs::EntriesFilter
      TYPE_MAPPING = {
        'QUnit' => '1. Main methods',
        'assert' => '2. Assertions',
        'callbacks' => '3. Callback events',
        'config' => '4. Configuration',
        'extension' => '5. Extension interface'
      }
      def get_name
        at_css('h1').content
      end

      def get_type
        main, *rest = *slug.split('/')
        TYPE_MAPPING[main]
      end
    end
  end
end
