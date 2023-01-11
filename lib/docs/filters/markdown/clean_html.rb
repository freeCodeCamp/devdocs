module Docs
  class Markdown
    class CleanHtmlFilter < Filter
      def call
        at_css('h1').content = 'Markdown'

        css('#ProjectSubmenu', 'hr').remove

        css('pre > code').each do |node|
          node.parent['data-language'] = 'markdown'
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
