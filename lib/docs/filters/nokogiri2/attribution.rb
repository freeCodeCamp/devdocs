# frozen_string_literal: true

module Docs
  class Nokogiri2
    class AttributionFilter < Docs::AttributionFilter
      def attribution_link
        url = current_url.to_s.sub! 'http://localhost', 'https://nokogiri.org/rdoc'
        %(<a href="#{url}" class="_attribution-link">#{url}</a>)
      end
    end
  end
end
