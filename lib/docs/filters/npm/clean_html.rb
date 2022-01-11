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

        css('pre').each do |node|
          node.content = node.css('.token-line').map(&:content).join("\n")
          node['data-language'] = 'javascript'
        end

        doc

      end
    end
  end
end
