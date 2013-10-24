module Docs
  class Http
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
        # Change title
        title = at_css 'h2'
        title.name = 'h1'
        title.inner_html = 'Hypertext Transfer Protocol &mdash; HTTP/1.1'

        # Remove "..." following each link
        css('span').each do |node|
          node.inner_html = node.first_element_child if node.first_element_child
        end
      end

      def other
        at_css('address').remove

        # Change title
        title = at_css 'h2'
        title.name = 'h1'
        title.at_css('a').remove
        title.content = "HTTP #{title.content}"

        # Update headings
        css('h3').each do |node|
          link = node.at_css('a')
          node.name = "h#{link.content.count('.') + 1}"
          node['id'] = link['id']
          link.remove
        end

        # Merge adjacent <pre> tags and remove indentation
        css('pre').each do |node|
          while (sibling = node.next_element) && sibling.name == 'pre'
            node.inner_html += "\n#{sibling.inner_html}"
            sibling.remove
          end
          node.inner_html = node.inner_html.strip_heredoc
        end
      end
    end
  end
end
