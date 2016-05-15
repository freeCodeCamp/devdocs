module Docs
  class Redis
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          at_css('ul')['class'] = 'commands'
        else
          title = at_css('h1')
          title.after("<pre>#{title.content.strip}</pre>")
          title.content = title.content.split(' ').first
        end

        css('nav', 'aside', 'form', '.anchor-link').remove

        css('> article', '.article-main', 'pre > code', '.container').each do |node|
          node.before(node.children).remove
        end

        css('.example > pre').each do |node|
          node.name = 'code'
        end

        doc
      end
    end
  end
end
