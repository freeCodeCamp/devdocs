module Docs
  class Liquid
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
      end

      def root
        doc = at_css('.home-banner')

        css('.btn-row').remove

        doc
      end

      def other
        doc = at_css('.content__area > .content')

        css('button.menu-button').remove

        css('code').each do |node|
          node.remove_attribute('class')
          node.content = node.content
        end

        css('pre', '.highlighter-rouge').each do |node|
          node.remove_attribute('class')
        end

        doc
      end
    end
  end
end
