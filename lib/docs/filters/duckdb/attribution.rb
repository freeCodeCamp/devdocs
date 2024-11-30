# frozen_string_literal: true

module Docs
  class Duckdb
    class AttributionFilter < Docs::AttributionFilter
      def attribution_link
        url = current_url.to_s.sub! 'http://localhost:8000', 'https://duckdb.org'
        %(<a href="#{url}" class="_attribution-link">#{url}</a>)
      end
    end
  end
end
