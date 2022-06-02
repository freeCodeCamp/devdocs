module Docs
  class Immutable
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('div')
        css('#algolia-autocomplete', '#algolia-docsearch').remove

        css('section', 'span', 'div[data-reactid]').each do |node|
          node.before(node.children).remove
        end

        css('.codeBlock').each do |node|
          node.name = 'pre'
          node.content = node.content
          node['data-language'] = 'ts'
        end

        css('*[data-reactid]').remove_attr('data-reactid')
        css('a[target]').remove_attr('target')
        css('*[class]').remove_attr('class')

        doc
      end
    end
  end
end
