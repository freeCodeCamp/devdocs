module Docs
  class Lodash
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.doc-container')

        css('> div', '> div > div', '.highlight').each do |node|
          node.before(node.children).remove
        end

        # Remove <code> inside headings
        css('h2', 'h3').each do |node|
          node.content = node.content
        end

        css('h3 + p > a:first-child').each do |node|
          node.parent.previous_element << %(<div class="_heading-links">#{node.parent.inner_html}</div>)
          node.parent.remove
        end

        # Remove code highlighting
        css('pre').each do |node|
          node.inner_html = node.inner_html.gsub('</div>', "</div>\n").gsub('&nbsp;', ' ').gsub('&amp;ampamp;', '&amp;amp;')
          node.content = node.content.strip
          node['data-language'] = 'javascript'
        end

        doc
      end
    end
  end
end
