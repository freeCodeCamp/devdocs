module Docs
  class Tcllib
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        # The first word after the `NAME` heading
        name = at_css('h1 + p')
        return name.content.strip.split[0]
      end

      def get_type
        # The types are the categories as indicated on each page (and on the
        # root page, toc0.md)
        category = at_css('a[name="category"]')
        if !category.nil?
          return category.parent.next.next.content
        end
        return 'Unfiled'
      end
    end
  end
end

