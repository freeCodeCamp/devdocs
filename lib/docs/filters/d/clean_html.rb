module Docs
  class D
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css("#content")

        css('#tools', '#copyright').remove

        css('td > b', 'h1 > span').each do |node|
          node.before(node.children).remove
        end

        css('span.d_inlinecode').each do |node|
          node.name = 'code'
          node.remove_attribute('class')
        end

        css('.keyval').each do |node|
          key = node.at_css('.key')
          dt = key.inner_html
          dd = if val = node.at_css('.val')
            val.inner_html
          else
            siblings = []
            siblings << key while key = key.next
            siblings.map(&:to_html).join
          end
          node.replace("<dl><dt>#{dt}</dt><dd>#{dd}</dd></dl>")
        end

        css('.description > .blankline:first-child + .quickindex').each do |node|
          node.next_element.remove if node.next_element && node.next_element['class'] == 'blankline'
          node.previous_element.remove
          node.parent.before(node)
        end

        css('div.summary', 'div.description').each do |node|
          node.name = 'p' unless node.at_css('p')
          node.css('.blankline').each { |n| n.replace('<br><br>') }
        end

        css('.d_decl').each do |node|
          node['id'] ||= node.at_css('.quickindex[id]')['id'].remove('quickindex.')

          node.css('.def-anchor[id]').each do |n|
            n.next_element['id'] ||= n['id']
          end

          node.css('.constraint').each do |n|
            n.content = "  Constraints: #{n.content}#{n.next.remove.content if n.next.text?}"
            n.name = 'small'
            n.remove_attribute('class')
          end

          node.css('code[id]').each do |n|
            n.name = 'strong'
            n.remove_attribute('class')
          end

          node.css('*').each do |n|
            n.before(n.children).remove unless n.name == 'br' || n.name == 'small' || n.name == 'strong'
          end

          node.inner_html = node.inner_html.remove(/<br>\z/)
        end

        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = 'd' if node['class'] && node['class'].include?('d_code')
        end

        css('div', 'code > a > code', 'code > code').each do |node|
          node.before(node.children).remove
        end

        css('a[href*="#."]').each do |node|
          node['href'] = node['href'].sub('#.', '#')
        end

        css('tr', 'td', 'code', 'pre', 'p', 'table').remove_attr('class')
        css('table').remove_attr('border').remove_attr('cellpadding').remove_attr('cellspacing')

        if base_url.path == '/spec/'
          css('a.anchor').each do |node|
            node.parent['id'] ||= node['id']
            node.before(node.children).remove
          end

          css('center').each do |node|
            node.before(node.children).remove
          end

          css('.fa-angle-left + a').remove
          css('a + .fa-angle-right').each { |node| node.previous_element.remove }
        end

        doc
      end
    end
  end
end
