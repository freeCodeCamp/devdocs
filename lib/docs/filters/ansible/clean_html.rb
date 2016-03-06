module Docs
  class Ansible
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#page-content')

        css('blockquote > div > pre:first-child:last-child', 'blockquote > div > ul:first-child:last-child').each do |node|
          node.ancestors('blockquote').first.before(node).remove
        end

        css('a > em').each do |node|
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
