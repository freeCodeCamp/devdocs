module Docs
  class Astro
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('article > section')

        css('.anchor-link').remove
        css('.avatar-list').remove

        css('header > h1').each do |node|
          node.parent.before(node).remove
        end

        css('pre').each do |node|
          node.content = node.css('.line').map(&:content).join("\n")
          node['data-language'] = node.ancestors('figure').first['class'][/lang-(\w+)/, 1]
          node.remove_attribute('style')
        end

        css('figcaption').each do |node|
          node.name = 'div'
          node['class'] = '_pre-heading'
        end

        css('figure').each do |node|
          node.before(node.children).remove
        end

        css('.cms-nav').remove

        css('.copy-button-wrapper, .copy-button-tooltip').remove

        doc
      end
    end
  end
end
