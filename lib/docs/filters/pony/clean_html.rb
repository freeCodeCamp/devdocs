module Docs
  class Pony
    class CleanHtmlFilter < Filter
      def call
        css('.headerlink').remove
        css('hr').remove

        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = 'pony'
        end

        doc
      end
    end
  end
end
