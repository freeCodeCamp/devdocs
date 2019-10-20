module Docs
  class Mariadb
    class CleanHtmlFilter < Filter
      def call
        # Return the empty doc if the EraseInvalidPagesFilter detected this page shouldn't be scraped
        return doc if doc.inner_html == ''

        # Extract main content
        @doc = at_css('#content')

        # Remove navigation at the bottom
        css('.simple_section_nav').remove

        # Remove table of contents
        css('.table_of_contents').remove

        # Add code highlighting and remove nested tags
        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = 'sql'
        end

        # Fix images
        css('img').each do |node|
          node['src'] = node['src'].sub('http:', 'https:')
        end

        # Remove navigation items containing only numbers
        css('.node_comments').each do |node|
          if node.content.scan(/\D/).empty?
            node.remove
          end
        end

        # Convert listings (pages like https://mariadb.com/kb/en/library/documentation/sql-statements-structure/) into tables
        css('ul.listing').each do |node|
          rows = []

          node.css('li:not(.no_data)').each do |li|
            name = li.at_css('.media-heading').content
            description = li.at_css('.blurb').content
            url = li.at_css('a')['href']
            rows << "<tr><td><a href=\"#{url}\">#{name}</a></td><td>#{description}</td></tr>"
          end

          table = "<table><thead><tr><th>Title</th><th>Description</th></tr></thead><tbody>#{rows.join('')}</tbody></table>"
          node.replace(table)
        end

        # Turn note titles into <strong> tags
        css('.product_title').each do |node|
          node.name = 'strong'
        end

        # Remove comments and questions
        css('.related_questions, #comments').remove
        css('h2').each do |node|
          if node.content == 'Comments'
            node.remove
          end
        end

        doc
      end
    end
  end
end
