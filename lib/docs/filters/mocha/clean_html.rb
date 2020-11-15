module Docs
  class Mocha
    class CleanHtmlFilter < Filter
      def call
        doc.child.remove until doc.child['id'] == 'installation'

        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = 'javascript'
        end

        css('#more-information ~ p').remove
        css('#more-information').remove

        css('h2 > a, h3 > a').each do |node|
          node.remove
        end

        doc
      end
    end
  end
end
