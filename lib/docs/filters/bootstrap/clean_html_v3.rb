module Docs
  class Bootstrap
    class CleanHtmlV3Filter < Filter
      def call
        at_css('div[role=main]').child.before(at_css('#content .container').inner_html)
        @doc = at_css('div[role=main]')

        css('h1, h2, h3, h4, h5').each do |node|
          node.name = node.name.sub(/\d/) { |i| i.to_i + 1 }
        end
        at_css('h2').name = 'h1'
        at_css('h1').content = 'Bootstrap 3' if root_page?

        css('hr', '.zero-clipboard', '.modal', '.panel-group').remove

        css('.bs-docs-section', '.table-responsive').each do |node|
          node.before(node.children).remove
        end

        css('> .show-grid', '.bs-example', '.bs-glyphicons', '.responsive-utilities-test').each do |node|
          if node.previous_element['class'].try(:include?, 'bs-example')
            node.remove
          else
            node.content = ''
            node.name = 'p'
            node['class'] = 'bs-example'
            node.remove_attribute('data-example-id')
            prev = node.previous_element
            prev = prev.previous_element until prev['id']
            node.inner_html = %(<a href="#{current_url}##{prev['id']}">Open example on getbootstrap.com</a>)
          end
        end

        css('.bs-example + figure').each do |node|
          node.previous_element.name = 'div'
        end

        css('div[class*="col-"]').each do |node|
          node['class'] = 'col'
        end

        css('figure.highlight').each do |node|
          code = node.at_css('code')
          node['data-language'] = code['data-lang']
          node.content = code.content
          node.name = 'pre'
        end

        css('table, tr, td, th, pre').each do |node|
          node.remove_attribute('class')
          node.remove_attribute('style')
        end

        css('thead td:empty').each do |node|
          node.name = 'th'
        end

        doc
      end
    end
  end
end
