module Docs
  class Erlang
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#content .innertube')

        # frontpage

        css('center:last-child').remove # copyright

        css('center').each do |node|
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

        # css('p > br:last-child').remove

        css('a[name]').each do |node|
          parent = node.parent
          parent = parent.parent while parent.name == 'span'
          parent['id'] = node['name']
          node.before(node.children).remove
        end

        css('h3').each do |node|
          node.name = 'h2'
          content = node.content
          node.content = content.capitalize if content == content.upcase
        end

        css('p > span.bold_code:first-child ~ br:last-child').each do |node|
          parent = node.parent
          parent.name = 'h3'
          parent['class'] = 'code'
          parent.css('*:not(a):not(br)').each { |n| n.before(n.children).remove }
          node.remove
          parent.inner_html = parent.inner_html.strip
        end

        css('span.code').each do |node|
          node.name = 'code'
        end

        css('pre *:not(a)').each do |node|
          node.before(node.children).remove
        end

        css('pre').each do |node|
          node.inner_html = node.inner_html.strip_heredoc
        end

        css('.REFBODY').each do |node|
          if node.element_children.length == 0
            node.name = 'p'
          else
            node.before(node.children).remove
          end
        end

        css('.REFTYPES').each do |node|
          next unless node.parent
          html = "<pre>"
          while node['class'] == 'REFTYPES'
            node.inner_html = node.inner_html.remove(/\n/).gsub('<br>', "\n")
            node.css('*:not(a)').each { |n| n.before(n.children).remove }
            html << node.inner_html.strip + "\n"
            node = node.next_element
            node.previous_element.remove
          end
          html.strip!
          html << "</pre>"
          node.before(html)
        end

        css('.REFTYPES').remove

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
