# frozen_string_literal: true

module Docs
  class Scala
    class CleanHtmlV3Filter < Filter
      def call
        # Remove unneeded elements
        css('.documentableFilter, .documentableAnchor, .documentableBrief').remove

        format_title
        format_signature
        format_top_links
        format_metadata

        # Remove the redundant long descriptions on the main page
        if slug == 'index'
          css('.contents').remove
        else
          format_members
        end
        
        simplify_html

        doc
      end

      private

      # Formats the title of the page
      def format_title
        cover_header = at_css('.cover-header')
        return if cover_header.nil?

        # Add the kind of page to the title
        icon = cover_header.at_css('.micon')
        types = {
          cl: 'Class',
          ob: 'Object',
          tr: 'Trait',
          en: 'Enum',
          ty: 'Type',
          pa: 'Package',
        }
        type_id = cover_header.at_css('.micon')['class']
        type_id.remove!('micon ')
        type_id.remove!('-wc')
        type = types[type_id.to_sym]
        name = CGI.escapeHTML cover_header.at_css('h1').text

        # Add the package name
        package = at_css('.breadcrumbs a:nth-of-type(3)').text
        package = package + '.' unless name.empty? || package.empty?

        # Replace the title
        title = root_page? ? 'Package root' : "#{type} #{package}#{name}".strip
        cover_header.replace "<h1>#{title}</h1>"
      end

      # Formats the signature block at the top of the page
      def format_signature
        signature = at_css('.signature')
        signature_annotations = signature.at_css('.annotations')
        signature_annotations.name = 'small' unless signature_annotations.nil?
        signature.replace "<h2 id=\"signature\">#{signature.inner_html}</h2>"
      end

      # Formats the top links (companion page, source code)
      def format_top_links
        # Companion page (e.g. List ↔ List$)
        links = []
        at_css('.attributes').css('dt').each do |dt|
          next if dt.content.strip != 'Companion:'
          dd = dt.next_sibling

          companion_link = dd.at_css('a')
          companion_link.content = "Companion #{companion_link.content}"
          links.append(companion_link.to_html)

          dt.remove
          dd.remove
        end

        # Source code
        at_css('.attributes').css('dt').each do |dt|
          next if dt.content.strip != 'Source:'
          dd = dt.next_sibling
          
          source_link = dd.at_css('a')
          source_link.content = 'Source code'
          links.append(source_link.to_html)

          dt.remove
          dd.remove
        end

        # Format the links
        title = at_css('h1')
        title.add_next_sibling("<div class=\"links\">#{links.join(' • ')}</div>")
      end

      # Metadata about the whole file (e.g. supertypes)
      def format_metadata
        # Format the values
        css('.tabs.single .monospace').each do |node|
          node.css('> div').each do |div|
            div['class'] = 'member'
          end

          node['class'] = 'related-types'

          if node.children.count > 15 # Hide too large lists
            node.replace "<details>
              <summary>#{node.children.count} types</summary>
              #{node.to_html}
            </details>"
          end
        end

        attributes = at_css('.attributes')

        # Change the HTML structure
        tabs_names = css('.tabs.single .names .tab')
        tabs_contents = css('.tabs.single .contents .tab')
        tabs_names.zip(tabs_contents).each do |name, contents|
          next if name.content == "Graph"

          attributes.add_child("<dt>#{name.content}</dt>")
          attributes.add_child("<dd>#{contents.inner_html.strip}</dd>")
        end

        convert_dl_to_table(attributes)

        tabs = at_css('.tabs')
        tabs.remove unless tabs.nil? || tabs.parent['class'] == 'membersList'
      end

      # Format the members (methods, values…)
      def format_members
        # Section headings
        css('.cover h2').each do |node|
          node.name = 'h3'
        end
        css('h2:not(#signature)').remove
        css(
          '.membersList h3',

          # Custom group headers for which Scaladoc generates invalid HTML
          # (<h3><p>…</p></h3>)
          '.documentableList > h3:empty + p'
        ).each do |node|
          node.name = 'h2'
          node.content = node.content
        end

        # Individual members
        css('.documentableElement').each do |element|
          header = element.at_css('.header')
          header.name = 'h3'

          id = element['id']
          element.remove_attribute('id')
          header['id'] = id unless id.nil?

          annotations = element.at_css('.annotations')
          annotations.name = 'small'
          header.prepend_child(annotations)

          # View source
          element.css('dt').each do |dt|
            next if dt.content.strip != 'Source:'
            dd = dt.next_sibling
            
            source_link = dd.at_css('a')
            source_link.content = 'Source'
            source_link['class'] = 'source-link'
            header.prepend_child(source_link)

            dt.remove
            dd.remove
          end

          # Format attributes as a table
          dl = element.at_css('.attributes')
          convert_dl_to_table(dl) unless dl.nil?

          # Remove the unnecessary wrapper element
          element.replace(element.inner_html)
        end

        # Remove deprecated sections
        css('.documentableList').each do |list|
          header = list.at_css('.groupHeader')
          list.remove if (header.text.downcase.include? 'deprecate' rescue false)
        end

        # Code blocks
        css('pre > code').each do |code|
          pre = code.parent
          pre['data-language'] = 'scala'
          pre.inner_html = code.inner_html
        end
      end

      # Simplify the HTML structure by removing useless elements
      def simplify_html
        # Remove unneeded parts of the document
        @doc = at_css('#content > div')

        # Remove the useless elements around members
        css('.documentableList > *').each do |element|
          element.parent = doc
        end
        at_css('.membersList').remove

        # Remove useless classes
        css('.header, .groupHeader, .cover, .documentableName').each do |element|
          element.remove_attribute('class')
        end

        # Remove useless attributes
        css('[t]').each do |element|
          element.remove_attribute('t')
        end

        # Remove useless wrapper elements
        css('.docs, .doc, .memberDocumentation, span, div:not([class])').each do |element|
          element.replace(element.children)
        end
      end

      def convert_dl_to_table(dl)
        table = Nokogiri::XML::Node.new('table', doc.document)
        table['class'] = 'attributes'

        dl.css('> dt').each do |dt|
          dd = dt.next_element
          has_dd = dd.name == 'dd' rescue false

          tr = Nokogiri::XML::Node.new('tr', doc.document)
          colspan = has_dd ? '' : ' colspan="2"' # handle <dt> without following <dt>
          tr.add_child("<th#{colspan}>#{dt.inner_html.sub(/:$/, '')}</th>")

          tr.add_child("<td>#{dd.inner_html}</td>") if has_dd

          table.add_child(tr)
        end

        dl.replace(table)
      end

    end
  end
end
