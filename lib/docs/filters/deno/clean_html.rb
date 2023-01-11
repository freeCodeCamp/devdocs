module Docs
  class Deno
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          @doc = at_css('h2[id]').parent.parent
        else
          @doc = at_css('article')
        end

        css('*[aria-label="Anchor"]').remove
        css('pre', '.tw-1nkr705').each do |node|
          node['data-language'] = 'typescript'
          node.name = 'pre'
        end
        css('.tw-8ej7ai').each do |node|
          code = node.at_css('.font-mono')
          next unless code
          code.parent.name = 'blockquote'
          code.name = 'code'
        end
        css('*[class]').remove_attribute('class')
        xpath('//a[text()="[src]"]').remove
        
        doc
      end
    end
  end
end
