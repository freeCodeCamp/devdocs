# frozen_string_literal: true

module Docs
  class Scala
    class CleanHtmlV3Filter < Filter
      def call
        # Remove unneeded elements
        css('.documentableFilter, .documentableAnchor, .documentableBrief').remove

        format_title
        format_top_links
        format_metadata
        format_members

        # Simplify the HTML structure
        @doc = at_css('#content > div')
        css('.documentableList > *').each do |element|
          element.parent = doc
        end
        at_css('.membersList').remove

        doc
      end

      def format_title
        # Add the kind of page to the title
        cover_header = at_css('.cover-header')
        unless cover_header.nil?
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

          package = at_css('.breadcrumbs a:nth-of-type(3)').text
          package = package + '.' unless name.empty? || package.empty?

          title = root_page? ? 'Package root' : "#{type} #{package}#{name}".strip
          cover_header.replace "<h1>#{title}</h1>"
        end

        # Signature
        signature = at_css('.signature')
        signature_annotations = signature.at_css('.annotations')
        signature_annotations.name = 'small' unless signature_annotations.nil?
        signature.replace "<h2 id=\"signature\">#{signature.inner_html}</h2>"
      end

      def format_top_links
        # Companion page
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

      def format_metadata
        # Metadata (attributes)
        css('.tabs.single .monospace').each do |node|
          node['class'] = 'related-types'

          if node.children.count > 15
            node.replace "<details>
              <summary>#{node.children.count} types</summary>
              #{node.to_html}
            </details>"
          end
        end

        attributes = at_css('.attributes')
        attributes.add_previous_sibling('<h3>Metadata</h3>')

        tabs_names = css('.tabs.single .names .tab')
        tabs_contents = css('.tabs.single .contents .tab')
        tabs_names.zip(tabs_contents).each do |name, contents|
          next if name.content == "Graph"

          attributes.add_child("<dt>#{name.content}</dt>")
          attributes.add_child("<dd>#{contents.inner_html.strip}</dd>")
        end
        at_css('.tabs').remove
      end

      def format_members
        # Headings
        css('.cover h2').each do |node|
          node.name = 'h3'
        end
        css('h2:not(#signature)').remove
        css(
          '.membersList h3',

          # Custom group headers for which Scaladoc generates invalid HTML
          '.documentableList > h3:empty + p'
        ).each do |node|
          node.name = 'h2'
          node.content = node.content
        end

        # Methods
        css('.documentableElement').each do |element|
          header = element.at_css('.header')
          header.name = 'h3'

          id = element['id']
          element.remove_attribute('id')
          header['id'] = id

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

    end
  end
end
