module Docs
  class Go
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          at_css('h1').content = 'Go Programming Language'

          # Remove empty columns
          css('tr:first-child + tr', 'th:first-child + th', 'td:first-child + td').remove

          # Remove links to unscraped pages
          css('td + td:empty').each do |node|
            node.previous_element.content = node.previous_element.content
          end
        end

        css('#plusone', '#nav', '.pkgGopher', '#footer', '.collapsed', '.permalink', '#pkg-callgraph').remove

        css('span[style]', '.toggleVisible', '.expanded', 'div.toggle').each do |node|
          node.before(node.children).remove
        end

        css('h2 a', 'h3 a').each do |node|
          if node['href'].include?('/src/')
            node.after %(<a href="#{node['href']}" class="source">Source</a>)
            node.before(node.children).remove
          end
        end

        # Remove triangle character
        css('h2', '.exampleHeading').each do |node|
          node.inner_html = node.inner_html.remove("\u25BE")
          node.name = 'h4' unless node.name == 'h2'
        end

        # Turn <dl> into <ul>
        css('#short-nav', '#manual-nav').each do |node|
          node.children = node.css('dd').tap { |nodes| nodes.each { |dd| dd.name = 'li' } }
          node.name = 'ul'
        end

        # Fix example markup
        css('.play').each do |node|
          node.children = node.at_css('.code').children
          node.name = 'pre'
        end

        # Remove code highlighting
        css('pre').each do |node|
          node['data-language'] = 'go'
          node.content = node.content
        end

        css('td[style]', 'ul[style]').remove_attr('style')
        css('.toggleButton[title]').remove_attr('title')
        css('.toggleButton').remove_attr('class')

        doc
      end
    end
  end
end
