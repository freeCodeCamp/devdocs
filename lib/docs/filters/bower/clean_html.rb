module Docs
  class Bower
    class CleanHtmlFilter < Filter
      def call
        title = at_css('.page-title')
        @doc = at_css('.main')
        doc.child.before(title)

        css('.site-footer').remove

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
