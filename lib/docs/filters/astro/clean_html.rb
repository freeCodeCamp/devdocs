module Docs
  class Astro
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('article > section')

        css('.anchor-link').remove

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

        doc
      end
    end
  end
end
