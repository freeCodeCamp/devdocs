module Docs
  class Redis
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          if root_page?
            slug_types = {}
            css('article[data-group]').each do |node|
              slug_types[node.at_css('a')['href']] = node['data-group']
            end
            # binding.pry
          end
        else
          title = at_css('h1')
          title.after("<pre>#{title.content.strip}</pre>")
          title.content = title.content.split(' ').first
        end

        css('nav', 'aside', '.page-feedback', '.anchor-link').remove

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
