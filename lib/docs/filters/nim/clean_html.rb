module Docs
  class Nim
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#documentId .container')

        css('.docinfo').remove

        content = at_css('#content')
        if content != nil
          at_css('#content').remove_attribute('class')
          @doc.add_child(at_css('#content').inner_html) 
        end

        css('> div.row').remove

        css('pre').each do |node|
          node['data-language'] = 'nim'
        end

        # remove link from headers
        css('h1 > a', 'h2 > a', 'h3 > a', 'h4 > a').each do |node|
          node.parent['id'] = node['id']
          node.parent.content = node.content
        end
        
        doc
      end
    end
  end
end
