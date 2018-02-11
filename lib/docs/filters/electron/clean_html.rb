module Docs
  class Electron
    class CleanHtmlFilter < Filter
      def call
        css('.header-link', 'hr + .text-center', 'hr').remove

        css('.grid', '.row', '.col-ms-12', 'ul.docs-list > ul.docs-list').each do |node|
          node.before(node.children).remove
        end

        if root_page?
          doc.child.before('<h1>Electron Documentation</h1>')

          css('h2 > a').each do |node|
            node.before(node.children).remove
          end
        end

        at_css('h2').name = 'h1' unless at_css('h1')

        css('h3', 'h4', 'h5').each do |node|
          node.name = node.name.sub(/\d/) { |i| i.to_i - 1 } unless node.name == 'h3' && node.at_css('code')
        end if !at_css('h2') && at_css('h4')

        css('pre').each do |node|
          node.content = node.content
        end

        doc
      end
    end
  end
end
