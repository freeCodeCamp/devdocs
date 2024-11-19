module Docs
  class Svelte
    class EntriesFilter < Docs::EntriesFilter
      def get_type
        page = at_css("main nav ul.sidebar li ul li a[href$='#{result[:path]}']")
        category = page.ancestors('li')[1]
        return category.css('h3').inner_text
      end

      def get_name
        page = at_css("main nav ul.sidebar li ul li a[href$='#{result[:path]}']")
        return page.inner_text
      end
    end
  end
end
