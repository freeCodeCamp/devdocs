module Docs
  class R
    class CleanHtmlFilter < Filter
      def call
        slug_parts = slug.split('/')

        if root_page?
          css('a[href$="/00index"]').each do |pkg|
            pkg['href'] = "/r-#{pkg['href'].split('/')[1]}/"
          end

        elsif slug_parts[0] == 'library'
          title = at_css('h2')
          title.inner_html = "<code>#{slug_parts[3]}</code> #{title.content}"

          summary = at_css('table[summary]')
          summary.remove if summary

          css('hr ~ *, hr').remove

        elsif slug_parts[-2] == 'manual'
          css('table.menu, div.header, hr, h2.contents-heading, div.contents, table.index-cp, table.index-vr, table[summary]').remove

          css('h2').each do |node|
            node.remove if node.content.end_with? ' index'
          end

          css('span[id] + h1, span[id] + h2, span[id] + h3, span[id] + h4, span[id] + h5, span[id] + h6').each do |node|
            # We need the first of the series of span with ids
            span = node.previous_element
            while span.previous
              prev = span.previous_element
              break unless prev.name == 'span' and prev['id']
              span.remove
              span = prev
            end

            node['id'] = span['id']
            span.remove

            css('div.example').each do |node|
              node.replace(node.children)
            end
          end

          css('h1 + h1').remove

          css('.footnote h5').each do |node|
            anchor = node.at_css('a[id]')
            footnote = node.next_sibling
            footnote.inner_html = "<strong>#{anchor.text}</strong>&nbsp;#{footnote.inner_html}"
            footnote['id'] = anchor['id']
            node.remove
          end
        end

        css('pre').each do |node|
          node['data-language'] = 'r'
        end

        doc
      end
    end
  end
end
