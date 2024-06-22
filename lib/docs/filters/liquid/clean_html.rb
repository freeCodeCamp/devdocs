module Docs
  class Liquid
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.content__area > .content')

        css('.home-banner', '.menu-button', '#used-by', '#used-by ~ *').remove

        css('.highlighter-rouge').each do |node|
          node.before(node.children).remove
        end

        css('pre').each do |node|
          node.content = node.content.strip
        end

        css('pre.highlight').each do |node|
          node['data-language'] = "liquid"
          node['class'] = "language-liquid"
        end

        doc
      end
    end
  end
end
