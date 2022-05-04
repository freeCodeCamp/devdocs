module Docs
  class Jest
    class CleanHtmlFilter < Filter
      def call
        at_css('.markdown').prepend_child(at_css('h1'))
        @doc = at_css('.markdown')

        at_css('h1').content = 'Jest Documentation' if root_page?

        css('hr', '.hash-link', 'button', '.badge').remove

        css('.prism-code').each do |node|
          node.parent.parent.before(node)
          node.name = 'pre'
          node.remove_attribute('class')
          node['data-language'] = 'typescript'
          node.content = node.css('.token-line').map(&:content).join("\n")
        end

        css('*').remove_attribute('style')

        doc
      end
    end
  end
end
