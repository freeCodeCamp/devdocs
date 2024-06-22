module Docs
  class VueRouter
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('main')

        # Remove unneeded elements
        css('.bit-sponsor, .header-anchor').remove

        css('.custom-block').each do |node|
          node.name = 'blockquote'

          title = node.at_css('.custom-block-title')
          title.name = 'strong' unless title.nil?
        end

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
