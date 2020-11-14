module Docs
  class SpringBoot
    class CleanHtmlFilter < Filter
      def call
             
        css('pre').each do |node|
          language =  node.children.first['data-lang']  if node.children.first.name == 'code'
          node['data-language'] = language
        end
      
        doc
      end
    end
  end
end
