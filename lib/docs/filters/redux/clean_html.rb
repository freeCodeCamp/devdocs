module Docs
  class Redux
    class CleanHtmlFilter < Filter
      def call

        css('h1, h2, h3, h4, h5').each do |node|
          node.css('a').remove
          node.remove_attribute('class')
          node.parent.before(node.parent.children).remove if node.parent.name == 'header'
        end

        css('h3').each do |node|
          node['id'] = node.content.gsub(/\(|\)/, '').downcase
        end

        css('pre').each do |node|
          node.content = node.css('.token-line').map(&:content).join("\n")
          node['data-language'] = 'javascript'
        end

        css('*').each do |node|
          node.remove_attribute('style')
          node.remove if node['class'] && node['class'].include?('copyButton')
        end

        doc

      end
    end
  end
end
