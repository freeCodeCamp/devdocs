module Docs
  class Docker
    class CleanHtmlOldFilter < Filter
      def call
        if root_page?
          doc.inner_html = "<h1>Docker Documentation</h1>"
          return doc
        end

        @doc = at_css('#DocumentationText')

        at_css('h2').name = 'h1' unless at_css('h1')

        css('.anchorLink', '.reading-time', 'hr', '> div[style*="margin-top"]:last-child').remove

        css('h1 + h1').each do |node|
          node.name = 'h2'
        end

        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = node.parent['class'][/language-(\w+)/, 1] if node.parent['class']
        end

        css('div.highlighter-rouge').each do |node|
          node.before(node.children).remove
        end

        css('code.highlighter-rouge').each do |node|
          node.content = node.content.gsub(/\s+/, ' ').strip
        end

        doc
      end
    end
  end
end
