module Docs
  class Yarn
    class CleanHtmlBerryFilter < Filter
      def call
        # Version notice
        css('#gatsby-focus-wrapper > div').remove

        # Logo and menu
        css('header > div:first-child').remove

        # Left nav and TOC
        css('main > div > div:first-child', 'aside').remove

        # Title and edit link
        css('article > div:first-child').remove

        # Bottom divider on index
        if slug == ''
          css('main > hr').remove
        end

        doc
      end
    end
  end
end
