module Docs
  class C
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          doc.inner_html = ' '
          return doc
        end

        css('#siteSub', '#contentSub', '.printfooter', '.t-navbar', '.editsection', '#toc', '.t-dsc-sep', '.t-dcl-sep',
            '#catlinks', '.ambox-notice', '.mw-cite-backlink', '.t-sdsc-sep:first-child:last-child').remove

        css('#bodyContent', '.mw-content-ltr', 'span[style]').each do |node|
          node.before(node.children).remove
        end

        css('h2 > span[id]', 'h3 > span[id]', 'h4 > span[id]', 'h5 > span[id]', 'h6 > span[id]').each do |node|
          node.parent['id'] = node['id']
          node.before(node.children).remove
        end

        css('table[style]', 'th[style]', 'td[style]').remove_attr('style')

        css('.t-dsc-hitem > td', '.t-dsc-header > td').each do |node|
          node.name = 'th'
          node.content = ' ' if node.content.empty?
        end

        css('tt').each do |node|
          node.name = 'code'
        end

        doc
      end
    end
  end
end
