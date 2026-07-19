module Docs
  class Bash
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('> div[id]') if at_css('> div[id]')
        # Remove the navigation header and footer and the lines underneath and above it
        at_css('.nav-panel + hr').try(:remove)
        line_above = at_xpath('//div[@class="header"]/preceding::hr[1]')
        line_above.remove unless line_above.nil?
        css('.nav-panel').remove

        css('.copiable-anchor', '.copiable-link').remove

        # Remove chapter and section numbers from title
        title_node = at_css('h1, h2, h3, h4, h5, h6')
        title_node.content = title_node.content.gsub(/(\d+\.?)+/, '').gsub('¶', '').strip
        title_node.name = 'h1'

        # Remove the "D. " from names like "D. Concept Index" and "D. Function Index"
        title_node.content = title_node.content[3..-1] if title_node.content.start_with?("D. ")

        # Remove columns containing a single space from tables
        # In the original reference they are used to add width between two columns
        xpath('//td[text()=" " and not(descendant::*)]').remove

        # The manual marks index targets with empty anchors (<a id="index-…"></a>), which the
        # clean_text filter strips. Move their ids onto the enclosing node so the index entries
        # keep linking to the right paragraph.
        css('a[id]').each do |node|
          next unless node.content.strip.empty?
          parent = node.parent
          if parent && parent['id'].blank?
            parent['id'] = node['id']
          else
            # Several anchors can share a parent; keep the extra ones alive by giving
            # them content the clean_text filter doesn't consider empty
            node.content = "​"
          end
        end

        # Remove the rows with a horizontal line in them from the index tables
        css('td[colspan="3"]').remove

        # Remove the empty spacer cells of the index tables
        css('td.printindex-index-entry').each do |node|
          previous = node.previous_element
          previous.remove if previous && previous.name == 'td' && previous.content.strip.empty?
        end

        # Remove additional text from menu entry and index entry cells
        css('td.printindex-index-entry, td.printindex-index-section').each do |node|
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
