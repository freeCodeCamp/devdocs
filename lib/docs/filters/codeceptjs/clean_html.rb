module Docs
  class Codeceptjs
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          doc.inner_html = ' '
          return doc
        end

        @doc = doc.at_css('div.reference div[role=main]')

        css('hr').remove

        unless at_css('h1')
          at_css('h2').name = 'h1'
        end

        unless at_css('h2')
          css('h3').each { |node| node.name = 'h2' }
          css('h4').each { |node| node.name = 'h3' }
        end

        css('pre > code').each do |node|
          node.parent['data-language'] = node['class'] if node['class']
          node.parent.content = node.parent.content
        end

        doc
      end
    end
  end
end
