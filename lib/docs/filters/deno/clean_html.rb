module Docs
  class Deno
    class CleanHtmlFilter < Filter
      def call
        if result[:path].start_with?('api/deno/')
          @doc = at_css('main')
        else
          @doc = at_css('main article .markdown-body')
        end

        css('code').each do |node|
          if node['class']
            lang = node['class'][/language-(\w+)/, 1]
          end
          node['data-language'] = lang || 'ts'
          node.remove_attribute('class')
        end

        css('a.header-anchor').remove()

        doc
      end
    end
  end
end
