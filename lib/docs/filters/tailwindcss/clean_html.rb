module Docs
  class Tailwindcss
    class CleanHtmlFilter < Filter
      def call
          clean_up

        # Remove code highlighting
        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = 'php'
        end

        doc
      end

      def clean_up
        @doc = doc.at_css('#content-wrapper')

        css('.location').remove

        # Replace .header with <h1>
        css('.page-header > h1').each do |node|
          node.content = 'Tailwind' if root_page?
          node.parent.before(node).remove
        end

        css('.container-fluid').each do |node|
          node.name = 'table'
          node.css('.row').each { |n| n.name = 'tr' }
          node.css('div[class^="col"]').each { |n| n.name = 'td' }
        end

        css('> div').each do |node|
          node.before(node.children).remove
        end

        # Remove <abbr>
        css('a > abbr').each do |node|
          node.parent['title'] = node['title']
          node.before(node.children).remove
        end

        # Clean up headings
        css('h1 > a', '.content', 'h3 > code', 'h3 strong', 'abbr').each do |node|
          node.before(node.children).remove
        end

        # Remove empty <td>
        css('td').each do |node|
          node.remove if node.content =~ /\A\s+\z/
        end

        # @doc = at_css('.docs_body')

        # Clean up headings
        css('h2 > a').each do |node|
          node.before(node.children).remove
        end

        css('p > a[name]').each do |node|
          node.parent.next_element['id'] = node['name']
        end

        css('blockquote').each do |node|
          node['class'] = 'tip' if node.inner_html.include?('{tip}')
          node.inner_html = node.inner_html.remove(/\{(tip|note)\}\s?/)
        end

        css('blockquote').each do |node|
          if node.inner_html.include?('You\'re browsing the documentation for an old version of Laravel.')
            node.remove
          end
        end
      end
    end
  end
end
