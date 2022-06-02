module Docs
  class Wordpress
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          doc.inner_html = '<h1>WordPress</h1>'
          return doc
        end

        article = at_css('article[id^="post-"]')
        @doc = at_css('article[id^="post-"]') unless article.nil?

        css('hr', '.screen-reader-text', '.table-of-contents',
            '.anchor', '.toc-jump', '.source-code-links', '.user-notes',
            '.show-more', '.hide-more').remove

        header = at_css('h1')
        header.content = header.content.strip
        doc.prepend_child header

        # Remove permalink
        css('h2 > a, h3 > a').each do |node|
          node.parent.remove_attribute('class')
          node.parent.remove_attribute('tabindex')
          node.parent.content = node.content
        end

        # Add PHP code highlighting
        css('pre').each do |node|
          node['data-language'] = 'php'
        end

        css('.source-code-container').each do |node|
          node.remove_class('source-code-container')
          node.name = 'pre'
          node.inner_html = node.inner_html.gsub(/<br\s?\/?>/i, "\n")
          node.content = node.content.strip
          node['data-language'] = 'php'
        end

        css('section').remove_attribute('class')

        doc
      end
    end
  end
end
