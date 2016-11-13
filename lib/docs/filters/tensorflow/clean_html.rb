module Docs
  class Tensorflow
    class CleanHtmlFilter < Filter
      def call
        css('hr').remove

        css('pre > code').each do |node|
          node.parent['class'] = node['class']
          node.parent.content = node.content
        end

        css('pre').each do |node|
          node.inner_html = node.inner_html.strip_heredoc

          next unless node['class']

          if node['class'] =~ /lang-c++/i
            node['data-language'] = 'cpp'
          elsif node['class'] =~ /lang-python/i
            node['data-language'] = 'python'
          end
        end

        css('b').each do |node|
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
