module Docs
  class Opentsdb
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.documentwrapper > .bodywrapper > .body > .section')

        css('> .section').each do |node|
          node.before(node.children).remove
        end

        css('tt.literal').each do |node|
          node.name = 'code'
          node.content = node.content
        end

        css('div[class*=highlight] .highlight pre').each do |node|
          node['data-language'] = node.parent.parent['class'][/highlight\-(\w+)/, 1]
          node.parent.parent.before(node)
          node.content = node.content.gsub('    ', '  ')
        end

        css('table').remove_attr('border')

        doc
      end
    end
  end
end
