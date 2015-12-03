module Docs
  class Erlang
    class AttributionFilter < Docs::AttributionFilter
      def attribution_link
        %(<a href="#{base_url}" class="_attribution-link">#{base_url}</a>)
      end
    end
  end
end
