module Docs
  class Eslint
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#main') if at_css('#main')
        @doc = at_css('.docs-main__content') if at_css('.docs-main__content')

        css('.eslint-ad').remove
        css('.glyphicon').remove
        css('hr', 'colgroup', 'td:empty').remove

        css('.container').each do |node|
          node.before(node.children).remove
        end

        css('.line-numbers-wrapper').remove
        css('pre.hljs').each do |node|
          lang = node['class'][/highlight-(\w+)/, 1]
          node['data-language'] = lang if lang
          node.content = node.content.strip
          node.name = 'pre'
          node.remove_attribute('class')
        end

        css('code', 'p').remove_attr('class')

        css('.resource__image', '.resource__domain').remove

        doc
      end
    end
  end
end
