module Docs
  class Erlang
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#content')

        # frontpage

        css('center:last-child').remove # copyright

        css('center', '.example').each do |node|
          node.before(node.children).remove
        end

        css('> br').remove

        css('> font[size="+1"]:first-child').each do |node|
          node.name = 'h1'
        end

        css('p > b:first-child:last-child > font[size="+1"]').each do |node|
          node = node.parent.parent
          node.name = 'h2'
          node.content = node.content
        end

        css('font').each do |node|
          node.before(node.children).remove
        end

        # others

        # Remove JS on-hover highlighting
        css('h3.title-link', 'h4.data-type-name', 'h4.func-head').each do |node|
          node.remove_attribute('onmouseover')
          node.remove_attribute('onmouseout')
        end

        css('a[name]').each do |node|
          node.before(node.children).remove
        end

        css('h3').each do |node|
          content = node.content
          node.content = content.capitalize if content == content.upcase
        end

        # Subsume "Types" heading under function head heading
        css('h4.func-head + .fun-types > h3.func-types-title')
          .each { |node| node.name = 'h5' }

        css('h3', 'h4', 'h5').each do |node|
          node.name = node.name.sub(/\d/) { |i| i.to_i - 1 }
        end

        # Convert <span/> code blocks to <code/> if inline otherwise
        # <pre><code/></pre>.
        css('span.bold_code', 'span.code', '.func-head > span.title-name').each do |node|
          node.remove_attribute('class')
          node.css('span.bold_code', 'span.code')
            .each { |n| n.before(n.children).remove }
          if node.at_css('br') then
            node.name = 'pre'
            node.inner_html = "<code>" +
                              node.inner_html.remove(/\n/).gsub('<br>', "\n").strip +
                              "</code>"
          else
            node.name = 'code'
            node.inner_html = node.inner_html.strip.gsub(/\s+/, ' ')
          end
        end

        css('*:not(.REFTYPES) > pre').each do |node|
          node['data-language'] = 'erlang'
          node.inner_html = node.inner_html.strip_heredoc
        end

        css('.REFBODY').each do |node|
          if node.element_children.length == 0
            node.name = 'p'
          else
            node.before(node.children).remove
          end
        end

        css('a[href^=javascript]').each { |n| n.before(n.children).remove }

        css('table').each do |node|
          node.remove_attribute('border')
          node.remove_attribute('cellpadding')
          node.remove_attribute('cellspacing')
        end

        css('td').each do |node|
          node.remove_attribute('align')
          node.remove_attribute('valign')
        end

        doc
      end
    end
  end
end
