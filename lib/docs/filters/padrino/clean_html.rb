module Docs
  class Padrino
    class CleanHtmlFilter < Filter
      def call
        title = at_css('#filecontents h1')
        @doc = at_css('#content')

        css('.highlight').each do |node|
          node.name = 'pre'
          node['data-lang'] = node.at_css('[data-lang]')['data-lang']
          node.content = node.content
        end

        doc
      end
    end
  end
end
