module Docs
  class Redux
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.page-inner section')

        css('#edit-link', 'hr').remove

        at_css('h2').name = 'h1' unless at_css('h1')

        if root_page?
          at_css('h1').content = 'Redux'

          at_css('a[href="https://www.npmjs.com/package/redux"]').parent.remove

          css('a[target]').each do |node|
            node.remove_attribute('target') unless node['href'].start_with?('http')
          end
        end

        css('a[id]:empty').each do |node|
          (node.next_element || node.parent.next_element)['id'] = node['id']
        end

        css('h1 > code').each do |node|
          node.before(node.children).remove
        end

        css('pre > code').each do |node|
          node.parent['data-language'] = node['class'][/lang-(\w+)/, 1] if node['class']
          node.parent.content = node.parent.content
        end

        doc
      end
    end
  end
end
