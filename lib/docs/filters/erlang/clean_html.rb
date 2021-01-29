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

        css('a[name]').each do |node|
          # parent = node.parent
          # parent = parent.parent while parent.name == 'span'
          (node.next_element || node.parent)['id'] ||= node['name']
          node.before(node.children).remove
        end

        css('h3').each do |node|
          node.name = 'h2'
          content = node.content
          node.content = content.capitalize if content == content.upcase
        end

        css('p > .bold_code:first-child ~ br:last-child').each do |node|
          parent = node.parent
          parent.name = 'h3'
          parent.css('> br').remove
          parent.css('> code').each do |code|
            code.css('*:not(a):not(br)').each { |n| n.before(n.children).remove }
            code.inner_html = code.inner_html.gsub('<br>', "\n").strip
          end
        end

        css('pre:not(.REFTYPES) *:not(a)', 'a[href^=javascript]').each do |node|
          node.before(node.children).remove
        end

        css('pre:not(.REFTYPES)').each do |node|
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
          html.gsub! %r{\n{2,}}, "\n"
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

        css('.bold_code').remove_attr('class')

        doc
      end
    end
  end
end
