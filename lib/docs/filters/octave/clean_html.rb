module Docs
  class Octave
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
        @doc = at_css('.contents')
      end

      def other
        css('.header', 'hr').remove

        css('.footnote > h3').each do |node|
          node.name = 'h5'
        end

        at_css('h2, h3, h4').name = 'h1'

        css('.example').each do |node|
          node.name = 'pre'
          node['data-language'] = 'matlab'
          node.content = node.content.strip
        end

        css('a[name] + dl, a[name] + h4').each do |node|
          node['id'] = node.previous_element['name']
        end

        css('dt > a[name]', 'th > a[name]').each do |node|
          node.parent['id'] = node['name']
          node.parent.content = node.parent.content.strip
        end

        css('h5 > a').each do |node|
          node.parent['id'] = node['name']
          node.parent.content = node.content
        end

        xpath('//td[text()=" " and not(descendant::*)]').remove
      end
    end
  end
end
