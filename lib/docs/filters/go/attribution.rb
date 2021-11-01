# frozen_string_literal: true

module Docs
  class Go
    class AttributionFilter < Docs::AttributionFilter
      def attribution_link
        url = current_url.to_s.sub! 'localhost:6060', 'golang.org'
        %(<a href="#{url}" class="_attribution-link">#{url}</a>)
      end
    end
  end
end
