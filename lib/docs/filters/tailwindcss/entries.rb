module Docs
  class Tailwindcss
    class EntriesFilter < Docs::EntriesFilter
      def get_type
        # /customizing-colors rediects to /colors, hence making css
        # selector below not to match the href
        if result[:path] == 'customizing-colors'
          selector = "#sidebar a[href='#{result[:path]}']"
        else
          selector = "#sidebar a[href='#{result[:path]}']"
        end

        check = at_css(selector).parent.parent.parent.css('h5').inner_text
        check
      end
    end
  end
end
