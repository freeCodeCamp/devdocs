module Docs
  class Jest
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('article')

        at_css('h1').content = 'Jest Documentation' if root_page?

        css('hr', '.hash-link', 'button', '.badge').remove

        css('.anchor').each do |node|
          node.parent['id'] = node['id']
          node.remove
        end

        css('.prism-code').each do |node|
          node.name = 'pre'
          node['data-language'] = 'js'
          node['data-language'] = node['class'][/language-(\w+)/, 1] if node['class']

          counter = 0

          node.css('.token-line').each do |subnode| # add newline each line of the code snippets
            if counter == 0
            else
              subnode.content = "\n#{subnode.content}"
            end

            counter += 1
          end

          node.content = node.content
        end

        doc
      end
    end
  end
end
