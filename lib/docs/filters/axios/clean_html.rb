module Docs
  class Axios
    class CleanHtmlFilter < Filter
      def call
        css('.links').remove
        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = node['class'][/lang-(\w+)/, 1]
        end
        doc
      end
    end
  end
end
