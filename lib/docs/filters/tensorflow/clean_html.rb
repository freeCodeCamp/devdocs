module Docs
  class Tensorflow
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.devsite-article')

        css('hr', '.devsite-nav', '.devsite-content-footer', '.devsite-article-body > br', '.devsite-article-meta', 'devsite-nav-buttons', '.devsite-banner', '.tfo-api img', '.tfo-notebook-buttons img', '.tfo-notebook-buttons>:first-child').remove

        css('aside.note').each do |node|
          node.name = 'blockquote'
        end

        css('.devsite-article-body', 'blockquote > blockquote', 'th > h2', 'th > h3').each do |node|
          node.before(node.children).remove
        end

        css('code[class] > pre').each do |node|
          node = node.parent
          node.content = node.content
          node.name = 'pre'
        end

        css('blockquote > pre:only-child', 'p > pre:only-child').each do |node|
          next if node.previous.try(:content).present? || node.next.try(:content).present?
          node.parent.before(node).remove
        end

        css('pre').each do |node|
          node.content = node.content.strip_heredoc

          if node['class'] && node['class'] =~ /lang-c++/i
            node['data-language'] = 'cpp'
          elsif node['class'] && node['class'] =~ /lang-python/i
            node['data-language'] = 'python'
          else
            node['data-language'] = version == 'Python' ? 'python' : 'cpp'
          end
        end

        css('code').each do |node|
          node.inner_html = node.inner_html.gsub(/\s+/, ' ')
        end

        css('> code', '> b').each do |node|
          node.replace("<p>#{node.to_html}</p>")
        end

        doc
      end
    end
  end
end
