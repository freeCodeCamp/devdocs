module Docs
  class Vagrant
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          doc.children = css('h1, .category')
          return doc
        end

        css('nav', '.sidebar', 'footer').remove

        css('.wrapper', '.page', '.container', '.row', '.page-contents', '.span8').each do |node|
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
