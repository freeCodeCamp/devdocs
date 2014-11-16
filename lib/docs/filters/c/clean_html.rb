module Docs
  class C
    class CleanHtmlFilter < Filter
      def call
        css('h1').remove if root_page?

        css('#siteSub', '#contentSub', '.printfooter', '.t-navbar', '.editsection', '#toc',
            '.t-dsc-sep', '.t-dcl-sep', '#catlinks', '.ambox-notice', '.mw-cite-backlink',
            '.t-sdsc-sep:first-child:last-child', '.t-example-live-link').remove

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

        css('tt', 'span > span.source-cpp').each do |node|
          node.name = 'code'
        end

        css('div > span.source-cpp').each do |node|
          node.name = 'pre'
          node.inner_html = node.inner_html.gsub('<br>', "\n")
          node.content = node.content
        end

        css('div > a > img[alt="About this image"]').each do |node|
          node.parent.parent.remove
        end

        css('area[href]').each do |node|
          node['href'] = node['href'].remove('.html')
        end

        css('h1 ~ .fmbox').each do |node|
          node.name = 'div'
          node.content = node.content
        end

        doc
      end
    end
  end
end
