module Docs
  class Redis
    class CleanHtmlFilter < Filter
      def call
        at_css('ul')['class'] = 'commands' if root_page?

        css('nav', 'aside', 'form').remove

        css('> article', 'pre > code').each do |node|
          node.before(node.children).remove
        end

        css('.example > pre').each do |node|
          node.name = 'code'
        end

        doc
      end
    end
  end
end
