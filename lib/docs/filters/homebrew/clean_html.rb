module Docs
  class Homebrew
    class CleanHtmlFilter < Filter
      def call
        css('hr')

        css('div.highlighter-rouge').each do |node|
          lang = node['class'][/language-(\w+)/, 1]
          node['data-language'] = lang if lang
          node.content = node.content.strip
          node.name = 'pre'
          node.remove_attribute('class')
        end

        doc
      end
    end
  end
end
