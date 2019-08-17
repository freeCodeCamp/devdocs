module Docs
  class SaltStack
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          doc.inner_html = '<h1>SaltStack</h1>'
          return doc
        end

        css('.headerlink').remove

        css('div[class^="highlight-"]').each do |node|
          node.name = 'pre'
          node['data-language'] = node['class'].scan(/highlight-([a-z]+)/i)[0][0]
          node.content = node.content.strip
        end

        css('.function > dt').each do |node|
          node.name = 'h3'
          node.content = node.content
        end

        doc
      end
    end
  end
end
