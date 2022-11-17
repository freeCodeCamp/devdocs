module Docs
  class Axios
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          return '<h1>Axios</h1><p>Promise based HTTP client for the browser and node.js</p><p>Axios is a simple promise based HTTP client for the browser and node.js. Axios provides a simple to use library in a small package with a very extensible interface.</p>'
        end
        @doc = at_css('main > .body')
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
