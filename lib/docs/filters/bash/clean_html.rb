module Docs
  class Bash
    class CleanHtmlFilter < Filter
      def call
        # Remove the navigation header and footer and the lines underneath and above it
        at_css('.header + hr').remove
        line_above = at_xpath('//div[@class="header"]/preceding::hr[1]')
        line_above.remove unless line_above.nil?
        css('.header').remove

        # Remove chapter and section numbers from title
        title_node = at_css('h1, h2, h3, h4, h5, h6')
        title_node.content = title_node.content.gsub(/(\d+\.?)+/, '').strip
        title_node.name = 'h1'

        # Remove the "D. " from names like "D. Concept Index" and "D. Function Index"
        title_node.content = title_node.content[3..-1] if title_node.content.start_with?("D. ")

        # Remove columns containing a single space from tables
        # In the original reference they are used to add width between two columns
        xpath('//td[text()=" " and not(descendant::*)]').remove

        # Add id's to additional entry nodes
        css('dl > dt > code').each do |node|
          # Only take the direct text (i.e. "<div>Hello <span>World</span></div>" becomes "Hello")
          node['id'] = node.xpath('text()').to_s.strip
        end

        # Fix hashes of index entries so they link to the correct hash on the linked page
        css('table[class^=index-] td[valign=top] > a').each do |node|
          path = node['href'].split('#')[0]
          hash = node.content

          # Fix the index entries linking to the Special Parameters page
          # There are multiple index entries that should link to the same paragraph on that page
          # Example: the documentation for "$!" is equal to the documentation for "!"
          if path.downcase.include?('special-parameters')
            if hash.size > 1 && hash[0] == '$'
              hash = hash[1..-1]
            end
          end

          node['href'] = path + '#' + hash
        end

        # Fix index table letter hashes (the "Jump to" hashes)
        css('table[class^=index-] th > a').each do |node|
          node['id'] = node['name']
        end

        # Remove the rows with a horizontal line in them from the index tables
        css('td[colspan="4"]').remove

        # Remove additional text from menu entry and index entry cells
        css('td[valign=top]').each do |node|
          link = node.at_css('a')
          node.children = link unless link.nil?
        end

        css('tt', 'code', 'table').remove_attr('class')

        css('tt').each do |node|
          node.name = 'code'
        end

        css('pre').each do |node|
          node.content = node.content
        end

        doc
      end
    end
  end
end
