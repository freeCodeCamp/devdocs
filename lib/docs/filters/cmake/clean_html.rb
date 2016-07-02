module Docs
  class Cmake
    class CleanHtmlFilter < Filter
      def call
        css('.headerlink', '#contents .topic-title').remove

        if root_page?
          css('#release-notes', '#index-and-search').remove

          css('h1').each do |node|
            node.name = 'h2'
          end
        end

        css('.contents > ul.simple > li:first-child:last-child').each do |node|
          node.parent.before(node.at_css('> ul'))
          node.remove
        end

        css('.toc-backref', '.toctree-wrapper', '.contents', 'span.pre', 'pre a > code').each do |node|
          node.before(node.children).remove
        end

        css('div[class*="highlight-"]').each do |node|
          pre = node.at_css('pre')
          pre.content = pre.content
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

        doc
      end
    end
  end
end
