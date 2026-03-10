module Docs
  class VueRouter
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('main > div:only-child > div:only-child', 'main', '.main')
        css('p + h1').each do |node|
          # breadcrumbs
          node.previous_element.remove
        end

        # Remove unneeded elements
        css('.bit-sponsor, .header-anchor', '.rulekit', 'div[hidden]', '.sponsors_outer').remove
        css('.vp-code-group > .tabs').remove

        css('.custom-block').each do |node|
          node.name = 'blockquote'

          title = node.at_css('.custom-block-title')
          title.name = 'strong' unless title.nil?
        end

        css('span.lang').remove
        css('pre > code:first-child').each do |node|
          node.parent['data-language'] = 'js'
          node.parent.content = node.css('.line').map(&:content).join("\n")
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
