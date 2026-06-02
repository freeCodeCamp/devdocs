# frozen_string_literal: true

module Docs
  class Powershell
    class AttributionFilter < Docs::AttributionFilter
      def attribution_link
        url = current_url.to_s.downcase
        base = self.version == 'Scripting' ? 'scripting' : 'module'
        url.sub! 'http://localhost/', "https://learn.microsoft.com/en-us/powershell/#{base}/"
        url.remove! %r{\.md$}
        url << "?view=powershell-" + self.version
        %(<a href="#{url}" class="_attribution-link">#{url}</a>)
      end
    end
  end
end
