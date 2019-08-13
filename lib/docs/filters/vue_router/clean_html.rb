module Docs
  class VueRouter
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.content')

        # Remove unneeded elements
        css('.bit-sponsor, .header-anchor').remove

        css('.custom-block').each do |node|
          node.name = 'blockquote'

          title = node.at_css('.custom-block-title')
          title.name = 'strong' unless title.nil?
        end

        doc
      end
    end
  end
end
