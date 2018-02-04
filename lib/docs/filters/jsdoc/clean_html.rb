module Docs
  class Jsdoc
    class CleanHtmlFilter < Filter
      def call
        at_css('h1').content = 'JSDoc' if root_page?

        css('.prettyprint').each do |node|
          node.content = node.content
          node['data-language'] = node['class'][/lang-(\w+)/, 1]
          node.remove_attribute('class')
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
