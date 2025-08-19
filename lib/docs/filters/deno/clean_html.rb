module Docs
  class Deno
    class CleanHtmlFilter < Filter
      def call
        if result[:path].start_with?('api/deno/')
          @doc = at_css('main[id!="content"] article', 'main[id!="content"]')
        else
          @doc = at_css('main article .markdown-body')
        end

        if at_css('.text-2xl')
          doc.prepend_child at_css('.text-2xl').remove
          at_css('.text-2xl').name = 'h1'
        end

        css('code').each do |node|
          if node['class']
            lang = node['class'][/language-(\w+)/, 1]
          end
          node['data-language'] = lang || 'ts'
          node.remove_attribute('class')
          if node.parent.name == 'div'
            node.content = node.content.strip
          end
        end

        css('a.header-anchor').remove()
        css('.breadcrumbs').remove()

        doc
      end
    end
  end
end
