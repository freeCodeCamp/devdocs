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

          if node['class'].include?('lang-c++')
            node['data-language'] = 'cpp'
          elsif node['class'].include?('lang-python')
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
