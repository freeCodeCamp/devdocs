module Docs
  class Matplotlib
    class CleanHtmlFilter < Filter
      def call
        css('.headerlink', 'hr').remove

        css('.toc-backref', '.toctree-wrapper', '.contents', 'span.pre', 'pre a > code').each do |node|
          node.before(node.children).remove
        end

        css('div[class*="highlight-"]').each do |node|
          pre = node.at_css('pre')
          pre.content = pre.content
          pre['data-language'] = node['class'][/highlight\-(\w+)/, 1]
          node.replace(pre)
        end

        css('span[id]:empty').each do |node|
          node.next_element['id'] = node['id']
          node.remove
        end

        css('.section').each do |node|
          if node['id']
            if node.first_element_child['id']
              node.element_children[1]['id'] = node['id']
            else
              node.first_element_child['id'] = node['id']
            end
          end

          node.before(node.children).remove
        end

        css('h2 > a > code').each do |node|
          node.parent.before(node.content).remove
        end

        css('dt[id]').each do |node|
          node.inner_html = "<code>#{node.content.strip}</code>"
        end

        css('li > p:first-child:last-child').each do |node|
          node.before(node.children).remove
        end

        css('table[border]').each do |node|
          node.remove_attribute 'border'
        end

        css('code[class]').each do |node|
          node.remove_attribute 'class'
        end

        css('h1').each do |node|
          node.content = node.content
        end

        css('p.rubric').each do |node|
          node.name = 'h4'
        end

        doc
      end
    end
  end
end
