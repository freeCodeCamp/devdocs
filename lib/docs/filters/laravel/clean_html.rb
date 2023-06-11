module Docs
  class Laravel
    class CleanHtmlFilter < Filter
      def call
        if subpath.start_with?('/api')
          api
        else
          other
        end

        # Remove code highlighting
        css('pre > code').each do |node|
          if node['data-lang'].eql?('nothing')
            # Ignore 'nothing' language
          else
            node.parent['data-language'] = node['data-lang']
          end
          # Prism uses `\n` to determine lines. Otherwise the lines will be
          # compacted.
          node.parent.content = node.css('.line').map(&:content).join("\n")
          node.remove
        end

        doc
      end

      def api
        @doc = doc.at_css('#page-content')

        css('.location').remove

        # Replace .header with <h1>
        css('.page-header > h1').each do |node|
          node.content = 'Laravel' if root_page?
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
      end

      def other
        @doc = at_css('#main-content')

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
