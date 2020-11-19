module Docs
  class Typescript
    class CleanHtmlFilter < Filter
      def call

        # Top menu bar
        css('#top-menu').remove
        css('.skip-to-main').remove

        # Sidebar
        css('#sidebar').remove

        # Pound symbol before each title
        css('.anchor').remove

        css('#handbook-content > h2').each do |node|
          node.name = 'h1'
        end

        # 'Next' title area
        css('.whitespace-tight').remove

        # Right side floating box
        css('.handbook-toc').remove

        css('#site-footer').remove

        doc

      end
    end
  end
end
