module Docs
  class Redux
    class CleanHtmlFilter < Filter
      def call

        css('h1, h2, h3, h4').each do |node|
          node.css('a').remove
        end

        css('h3').each do |node|
          node['id'] = node.content.gsub(/\(|\)/, '').downcase
        end

        css('.codeBlockLines_b7E3').each do |node|
          node.remove_attribute('style')
          node.name = 'pre'
          node['data-language'] = 'javascript'

          node.css('div, span').each do |subnode|
            subnode.remove_attribute('style')
          end

        end

        css('.copyButton_10dd').remove

        doc

      end
    end
  end
end
