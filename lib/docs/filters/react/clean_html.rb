module Docs
  class React
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.inner-content')

        if root_page?
          at_css('h1').content = 'React Documentation'
        end

        css('.docs-prevnext', '.hash-link', '.edit-page-link').remove

        css('a.anchor').each do |node|
          node.parent['id'] = node['name']
        end

        css('.highlight').each do |node|
          node.name = 'pre'
          node['data-lang'] = node.at_css('[data-lang]')['data-lang']
          node.content = node.content
        end

        css('blockquote > p:first-child').each do |node|
          node.remove if node.content.strip == 'Note:'
        end

        doc
      end
    end
  end
end
