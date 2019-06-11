module Docs
  class Bootstrap
    class CleanHtmlV4Filter < Filter
      def call
        @doc = at_css('.bd-content')

        at_css('h1').content = 'Bootstrap 4' if root_page?

        css('hr', '.bd-clipboard', '.modal', '.bd-example .bd-example').remove

        css('#markdown-toc-contents').each do |node|
          node.parent.remove
        end

        css('.bd-example-row', '.bd-example-border-utils').each do |node|
          node.before(node.children).remove
        end

        css('.bd-example', '.responsive-utilities-test').each do |node|
          next unless node.previous_element

          if node.previous_element['class'].try(:include?, 'bd-example')
            node.remove
          else
            node.content = ''
            node.name = 'p'
            node['class'] = 'bd-example'
            node.remove_attribute('data-example-id')
            prev = node.previous_element
            prev = prev.previous_element until prev['id']
            node.inner_html = %(<a href="#{current_url}##{prev['id']}">Open example on getbootstrap.com</a>)
          end
        end

        css('.bd-example + .highlight').each do |node|
          node.previous_element.name = 'div'
        end

        css('div[class*="col-"]').each do |node|
          node['class'] = 'col'
        end

        css('.highlight').each do |node|
          code = node.at_css('code')
          node['data-language'] = code['data-lang']
          node.content = code.content
          node.name = 'pre'
        end

        css('bd-callout h3').each do |node|
          node.name = 'h4'
        end

        css('thead td').each do |node|
          node.name = 'th'
        end

        css('table, tr, td, th, pre, code').each do |node|
          node.remove_attribute('class')
          node.remove_attribute('style')
        end

        css('[class*="bd-"]').each do |node|
          node['class'] = node['class'].gsub('bd-', 'bs-')
        end

        doc
      end
    end
  end
end
