module Docs
  class Openlayers
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('section')
    
        at_css('h2').name = 'h1' if at_css('h2')

        css('pre.prettyprint').each do |node|
          node['data-language'] = node['class'].include?('html') ? 'html' : 'js'
          node.content = node.content
        end
        
        doc
      end
    end
  end
end
