module Docs
  class Cppref
    class CleanHtmlFilter < Filter
      def call
        css('h1').remove if root_page?

        css('.t-dcl-rev-aux td[rowspan]').each do |node|
          rowspan = node['rowspan'].to_i
          node['rowspan'] = node.ancestors('tbody').css('tr').length if rowspan > 3
        end

        css('#siteSub', '#contentSub', '.printfooter', '.t-navbar', '.editsection', '#toc',
            '.t-dsc-sep', '.t-dcl-sep', '#catlinks', '.ambox-notice', '.mw-cite-backlink',
            '.t-sdsc-sep:first-child:last-child', '.t-example-live-link',
            '.t-dcl-rev-num > .t-dcl-rev-aux ~ tr:not(.t-dcl-rev-aux) > td:nth-child(2)').remove

        css('#bodyContent', '.mw-content-ltr', 'span[style]', 'div[class^="t-ref"]', '.t-image',
            'th > div', 'td > div', '.t-dsc-see', '.mainpagediv', 'code > b', 'tbody').each do |node|
          node.before(node.children).remove
        end

        css('div > ul').each do |node|
          node.parent.before(node.parent.children).remove
        end

        css('dl > dd:first-child:last-child > ul:first-child:last-child').each do |node|
          dl = node.parent.parent
          if dl.previous_element && dl.previous_element.name == 'ul'
            dl.previous_element << node
            dl.remove
          else
            dl.before(node).remove
          end
        end

        css('dl > dd:first-child:last-child').each do |node|
          node.parent.before(node.children).remove
        end

        css('ul').each do |node|
          while node.next_element && node.next_element.name == 'ul'
            node << node.next_element.children
            node.next_element.remove
          end
        end

        css('h2 > span[id]', 'h3 > span[id]', 'h4 > span[id]', 'h5 > span[id]', 'h6 > span[id]').each do |node|
          node.parent['id'] = node['id']
          node.before(node.children).remove
        end

        css('table[style]', 'th[style]', 'td[style]').remove_attr('style')
        css('table[cellpadding]').remove_attr('cellpadding')

        css('.t-dsc-hitem > td', '.t-dsc-header > td').each do |node|
          node.name = 'th'
          node.content = ' ' if node.content.empty?
        end

        css('tt', 'span > span.source-cpp', 'span.t-c', 'span.t-lc', 'span.t-dsc-see-tt').each do |node|
          node.name = 'code'
          node.remove_attribute('class')
          node.content = node.content unless node.at_css('a')
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

        css('p').each do |node|
          while node.next && (node.next.text? || node.next.name == 'a' || node.next.name == 'code')
            node << node.next
          end
          node.inner_html = node.inner_html.strip
          node << '.' if node.content =~ /[a-zA-Z0-9\)]\z/
          node.remove if node.content.blank? && !node.at_css('img')
        end

        css('pre').each do |node|
          node['data-language'] = if node['class'].try(:include?, 'cpp') || node.parent['class'].try(:include?, 'cpp')
            'cpp'
          else
            'c'
          end
          node.remove_attribute('class')
          node.content = node.content.gsub("\t", ' ' * 8)
        end

        css('code code', '.mw-geshi').each do |node|
          node.before(node.children).remove
        end

        css('h1 ~ .fmbox').each do |node|
          node.name = 'div'
          node.content = node.content
        end

        css('img').each do |node|
          node['src'] = node['src'].sub! %r{https://upload.cppreference.com/mwiki/(images/[^"']+?)}, 'http://upload.cppreference.com/mwiki/\1'
        end

        # temporary solution due lack of mathjax/mathml support
        css('.t-mfrac').each do |node|
          fraction = Nokogiri::XML::Node.new('span', doc.document)

          node.css('td').each do |node|
            fraction.add_child("<span>#{node.content}</span>")
          end

          fraction.last_element_child().before("<span>/</span>")

          node.before(fraction)
          node.remove
        end

        doc
      end
    end
  end
end
