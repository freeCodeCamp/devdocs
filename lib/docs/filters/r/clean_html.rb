module Docs
  class R
    class CleanHtmlFilter < Filter
      def call
        slug_parts = slug.split('/')
        if slug_parts[0] == 'library'
          title = at_css('h2')
          title.inner_html = "<code>#{slug_parts[3]}</code> #{title.content}"

          summary = at_css('table[summary]')
          summary.remove if summary

        elsif slug_parts[-2] == 'manual'
          css('span[id] + h1, span[id] + h2, span[id] + h3, span[id] + h4, span[id] + h5, span[id] + h6').each do |node|
            id = node.previous['id']
            node.previous.remove
            node['id'] = id.sub(/-1$/, '') if id
          end
          css('table.menu, div.header, hr').remove

          css('.footnote h5').each do |node|
            anchor = node.at_css('a[id]')
            footnote = node.next_sibling
            footnote.inner_html = "<strong>#{anchor.text}</strong>&nbsp;#{footnote.inner_html}"
            footnote['id'] = anchor['id']
            node.remove
          end
        end

        doc
      end
    end
  end
end
