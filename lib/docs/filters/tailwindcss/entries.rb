module Docs
  class Tailwindcss
    class EntriesFilter < Docs::EntriesFilter
      def get_type
        # We are only interested in children list items
        

        anchor = at_css(get_selector)
        title =
          if version == '3'
            anchor.ancestors('li')[1].css('h5')
          else
            anchor.ancestors('ul').last.previous_element
          end

        return title.inner_text
      end

      def get_name
        # We are only interested in children list items
        item = at_css(get_selector)

        return item.inner_text
      end

      private

      def get_selector
        if version == '3'
          "nav li li a[href='#{result[:path]}']"
        else
          "nav li a[href*='#{result[:path]}']"
        end
      end
    end
  end
end
