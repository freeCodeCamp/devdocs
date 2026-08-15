module Docs
  class Vueuse
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        heading = at_css('h1').dup
        # The permalink holds a zero-width space, which would trail the name.
        heading.css('.header-anchor').remove
        heading.content.strip
      end

      def get_type
        # Every function page states its category right below the title.
        category = at_css('.vp-doc a[href*="category="]')
        return category.content.strip if category

        # The add-on packages' readmes don't, but the sidebar names every category.
        if (package = slug[%r{\A([^/]+)/readme\z}, 1])
          heading = css('.VPSidebar h2').find { |node| node.content.casecmp?("@#{package}") }
          return heading.content if heading
        end

        'Guide'
      end
    end
  end
end
