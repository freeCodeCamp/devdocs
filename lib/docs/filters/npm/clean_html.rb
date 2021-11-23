module Docs
  class Npm
    class CleanHtmlFilter < Filter
      def call

        at_css('#___gatsby').before(at_css('h1'))

        css('details').remove

        css('.dZYhXG', '.fONtKn').remove

        css('.kSYjyK').remove

        css('.cDvIaH').remove

        css('.jRndWL').remove_attribute('style')

        doc

      end
    end
  end
end
