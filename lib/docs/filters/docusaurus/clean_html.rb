module Docs
  class Docusaurus
    class CleanHtmlFilter < Filter
      def call
        doc = at_css '.post article div span'

        doc.css('h1, h2, h3, h4, h5, h6').each do |header|
          a = header.at_css('.anchor')
          header['id'] = a['id']
          a.remove

          header.at_css('.hash-link').remove
        end

        doc.children.before doc.document.at_css('.postHeader h1')

        css('pre > code.hljs').each do |node|
          node.parent['data-language'] = node['class'][/languages-\s*(\w+)/, 1]
        end

        css('pre').each do |node|
          node.content = node.content
        end

        doc
      end
    end
  end
end
