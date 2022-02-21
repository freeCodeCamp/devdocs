module Docs
  class Tailwindcss
    class EntriesFilter < Docs::EntriesFilter
      def get_type
        # We are only interested in children list items
        selector = "nav li li a[href='#{result[:path]}']"

        anchor = at_css(selector)
        category_list = anchor.ancestors('li')[1]
        title = category_list.css('h5')

        return title.inner_text
      end

      def get_name
        # We are only interested in children list items
        selector = "nav li li a[href='#{result[:path]}']"
        item = at_css(selector)

        return item.inner_text
      end
    end
  end
end
