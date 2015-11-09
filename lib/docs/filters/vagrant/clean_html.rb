module Docs
  class Vagrant
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.page-contents .span8')

        css('hr').remove

        css('pre > code').each do |node|
          node.parent['class'] = node['class']
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
