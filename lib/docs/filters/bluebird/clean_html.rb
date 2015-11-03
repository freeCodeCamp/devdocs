module Docs
  class Bluebird
    class CleanHtmlFilter < Filter
      def call
        at_css('.post-content').first_element_child.remove
        css('pre').add_class('language-javascript')
        doc
      end
    end
  end
end
