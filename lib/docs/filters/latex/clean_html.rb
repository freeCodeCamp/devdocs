module Docs
  class Latex
    class CleanHtmlFilter < Filter
      def call
        css('hr, div.header, div.referenceinfo').remove
        css('div.shortcontents, div.contents, h2.shortcontents-heading, h2.contents-heading, h1.settitle').remove if root_page?

        css('span[id] + h1, span[id] + h2, span[id] + h3, span[id] + h4, span[id] + h5, span[id] + h6').each do |node|
          id = node.previous['id']
          node.previous.remove
          node['id'] = id.sub(/-\d$/, '') if id
        end

        css('h1, h2, h3, h4').each { |node| node.content = node.content.sub /^[0-9A-Z]+(\.[0-9]+)* /, '' }

        css('div.example').each do |node|
          node.replace(node.children)
        end

        css('pre').each do |node|
          node.delete 'class'
          node['data-language'] = 'latex'
        end

        doc
      end
    end
  end
end
