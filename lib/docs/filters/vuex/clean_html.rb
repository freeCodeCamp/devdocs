module Docs
  class Vuex
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('main')

        # Remove video from root page
        css('a[href="#"]').remove if root_page?

        # Remove unneeded elements
        css('.header-anchor').remove

        # Remove data-v-* attributes
        css('*').each do |node|
          node.attributes.each_key do |attribute|
            node.remove_attribute(attribute) if attribute.start_with? 'data-v-'
          end
        end

        doc
      end
    end
  end
end
