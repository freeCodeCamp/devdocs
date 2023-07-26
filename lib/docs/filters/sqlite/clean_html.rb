module Docs
  class Sqlite
    class CleanHtmlFilter < Filter
      def call
        at_css('.nosearch').remove

        css('.rightsidebar', 'hr', '.sh_mark', '.fancy_toc > a', '.fancy_toc_mark', 'h[style*="none"]',
            '#docsearch',
            'a[href$="intro.html"] > h2', 'a[href$="intro"] > h2', '#document_title + #toc_header',
            '#document_title ~ #toc').remove
        css('a[href$="intro.html"]:empty', 'a[href$="intro"]:empty').remove

        css('.fancy_title', '> h2[align=center]', '#document_title').each do |node|
          node.name = 'h1'
        end

        unless at_css('h1')
          if at_css('h2') && at_css('h2').content == context[:html_title]
            at_css('h2').name = 'h1'
          else
            doc.child.before("<h1>#{context[:html_title]}</h1>")
          end
        end

        if root_page?
          at_css('h1').content = 'SQLite Documentation'
        end

        css('.codeblock', '.fancy', '.nosearch', '.optab > blockquote', '.optab').each do |node|
          node.before(node.children).remove
        end

        css('blockquote').each do |node|
          next unless node.at_css('b')
          node.name = 'pre'
          node.inner_html = node.inner_html.gsub('<br>', "\n")
        end

        css('.todo').each do |node|
          node.inner_html = "TODO: #{node.inner_html}"
        end

        css('blockquote > pre', 'a > h1', 'a > h2', 'center > table', 'ul > ul').each do |node|
          node.parent.before(node.parent.children).remove
        end

        css('table > tr:first-child:last-child > td:first-child:last-child > pre',
            'table > tr:first-child:last-child > td:first-child:last-child > ul').each do |node|
          node.ancestors('table').first.replace(node)
        end

        css('a[name]').each do |node|
          if node.next_element
            if node.next_element['id']
              node.next_element.next_element['id'] ||= node['name']
            else
              node.next_element['id'] = node['name']
            end
            node.remove
          elsif node.parent.name == 'p'
            node['id'] = node['name']
            node.parent.after(node.remove)
          else
            node.parent['id'] ||= node['name']
            node.remove
          end
        end

        unless at_css('h2')
          css('h1 ~ h1').each do |node|
            node.name = 'h2'
          end
        end

        css('tt').each do |node|
          node.name = 'code'
        end

        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = 'sql'
        end

        css('button[onclick]').each do |node|
          node['class'] = '_btn'
          node['data-toggle'] = node['onclick'][/hideorshow\("\w+","(\w+)"\)/, 1]
          node.remove_attribute('onclick')
        end

        css('svg *[style], svg *[fill]').each do |node|
          # transform style in SVG diagrams, e.g. on https://sqlite.org/lang_insert.html
          if node['style'] == 'fill:rgb(0,0,0)' or node['fill'] == 'rgb(0,0,0)'
            node.add_class('fill')
            node.remove_attribute('fill')
          elsif node['style'] == 'fill:none;stroke-width:2.16;stroke:rgb(0,0,0);'
            node.add_class('stroke')
          elsif node['style'] == 'fill:none;stroke-width:2.16;stroke-linejoin:round;stroke:rgb(0,0,0);'
            node.add_class('stroke')
          elsif node['style'] == 'fill:none;stroke-width:3.24;stroke:rgb(211,211,211);'
            node.add_class('stroke')
          elsif node['style']
            raise NotImplementedError, "SVG style #{node['style']}"
          end
          node.remove_attribute('style')
        end

        css('.imgcontainer > div[style]').add_class('imgcontainer')
        css('*[style]:not(.imgcontainer)').remove_attr('style')
        css('.imgcontainer').remove_class('imgcontainer')

        css('*[align]').remove_attr('align')
        css('table[border]').remove_attr('border')

        doc
      end
    end
  end
end
