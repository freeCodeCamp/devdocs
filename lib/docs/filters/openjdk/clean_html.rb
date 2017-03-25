module Docs
  class Openjdk
    class CleanHtmlFilter < Filter
      def call
        # Preserve internal fragment links
        # Transform <a name="foo"><!-- --></a><bar>text</bar>
        #      into <bar id="foo">text</bar>
        css('a[name]').each do |node|
          if node.children.all?(&:blank?)
            node.next_element['id'] = node['name'] if node.next_element
            node.remove
          end
        end

        # Find the main container
        # Root page have three containers, we use the second one
        container = at_css('.contentContainer' + (root_page? ? ':nth-of-type(2)' : ''))

        # Move description to the container top
        if description_link = at_css('a[href$=".description"]')
          target = description_link['href'][1..-1]
          description_nodes = xpath("//*[@id='#{target}'] | //*[@id='#{target}']/following-sibling::*")
          container.prepend_child(description_nodes)
          description_nodes.at_css('h2:contains("Description")')&.remove
          description_link.parent.remove
        end

        # Remove superfluous and duplicated content
        css('.subTitle', '.docSummary', '.summary caption', 'caption span.tabEnd').remove
        css('table[class$="Summary"] > tr > th').each do |th|
          th.parent.remove
        end
        css('h3[id$=".summary"]').each do |header|
          # Keep only a minimal list of annotation required/optional elements
          # as with "Methods inherited from class"
          if header['id'].match? %r{\.element\.summary$}
            table_summary = header.next_element
            code_summary = header.document.create_element 'code'
            table_summary.css('.memberNameLink a').each_with_index do |element, index|
              code_summary << header.document.create_text_node(', ') if index > 0
              code_summary << element
            end
            table_summary.replace(code_summary)
          # Remove summary element if detail exists
          elsif detail_header = at_css("h3[id='#{header['id'].sub('summary','detail')}']")
            header.next_element.remove
            header.replace(detail_header.parent.children)
          end
        end
        at_css('.details')&.remove unless at_css('.details h3')
        css('h3[id$=".summary"]', 'h3[id$=".detail"]', 'caption span').each do |header|
          header.name = 'h3' if header.name == 'span'
          content = header.content
          content.remove! ' Summary'
          content.remove! ' Detail'
          header.content = content.pluralize
        end
        css('h4').each do |entry_header|
          entry_pre = entry_header.next_element
          entry_header.children = entry_pre.children
          entry_pre.remove
        end

        # Keep only header and container
        container.prepend_child(at_css('.header'))
        @doc = container

        # Remove packages not belonging to this version
        if root_page?
          at_css('.overviewSummary caption h3').content =
            version + ' ' +
            at_css('.overviewSummary caption h3').content
          css('.overviewSummary td.colFirst a').each do |node|
            unless context[:only_patterns].any? { |pattern| node['href'].match? pattern }
              node.parent.parent.remove
            end
          end
        end

        # Syntax highlighter
        css('pre').each do |node|
          node['data-language'] = 'java'
        end
        doc
      end
    end
  end
end
