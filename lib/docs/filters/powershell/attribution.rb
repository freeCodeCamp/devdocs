# frozen_string_literal: true

module Docs
  class Powershell
    class AttributionFilter < Docs::AttributionFilter
      def attribution_link
        url = current_url.to_s.downcase
        url.sub! 'http://localhost/', 'https://learn.microsoft.com/en-us/powershell/module/'
        url.remove! %r{\.html$}
        url << "?view=powershell-" + self.version
        %(<a href="#{url}" class="_attribution-link">#{url}</a>)
      end
    end
  end
end
