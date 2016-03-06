module Docs
  class Tensorflow
    class CleanHtmlFilter < Filter
      def call
        css('hr').remove

        css('pre > code').each do |node|
          node.parent['class'] = node['class']
          node.parent.content = node.content
        end

        css('b').each do |node|
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
