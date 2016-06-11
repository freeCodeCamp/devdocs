module Docs
  class Vagrant
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#main-content .bs-docs-section')

        css('hr').remove

        css('pre > code').each do |node|
          node.parent['data-language'] = 'ruby'
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
