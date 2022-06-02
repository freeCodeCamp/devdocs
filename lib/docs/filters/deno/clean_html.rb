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
        css('*[class]').remove_attribute('class')
        css('pre').each do |node|
          node['data-language'] = 'typescript'
        end
        xpath('//a[text()="[src]"]').remove
        
        doc
      end
    end
  end
end
