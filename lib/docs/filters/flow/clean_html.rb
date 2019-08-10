module Docs
  class Flow
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
        @doc = at_css('.bg-faded + .container')

        css('.row', '.col-lg-4', '.card-block').each do |node|
          node.before(node.children).remove
        end

        css('a.card').each do |node|
          node.at_css('.text-primary').replace %(<br><a href="#{node['href']}">Read more</a>)
          node.before(node.children).remove
        end
      end

      def other
        @doc = at_css('.article')

        css('.nav-tabs', '#select-platform', '.guide-controls + .list-group', '.guide-controls', 'hr').remove

        css('.guide-content', '.tabs', '.tab-content').each do |node|
          node.before(node.children).remove
        end

        css('a[id].toc').each do |node|
          node.parent['id'] = node['id']
          node.remove
        end

        unless at_css('h2')
          css('h3', 'h4', 'h5').each do |node|
            node.name = node.name.sub(/\d/) { |i| i.to_i - 1 }
          end
        end

        unless at_css('h3')
          css('h4', 'h5').each do |node|
            node.name = node.name.sub(/\d/) { |i| i.to_i - 1 }
          end
        end

        css('.editor').each do |node|
          pre = node.at_css('.editor-code > pre')
          pre['data-language'] = 'javascript'
          pre.content = pre.content
          node.replace(pre)
        end

        css('div.highlighter-rouge').each do |node|
          node['data-language'] = node['class'][/language-(\w+)/, 1] if node['class']
          node.content = node.content.strip
          node.name = 'pre'
        end

        css('.highlighter-rouge').remove_attr('class')
      end
    end
  end
end
