module Docs
  class Yarn
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
        @doc = at_css('.hero + .container')

        at_css('.row').remove
        css('> .container', 'hr').remove

        css('.row', '.col-lg-4', '.card-block').each do |node|
          node.before(node.children).remove
        end

        css('a.card').each do |node|
          node.at_css('.float-right').replace %(<br><a href="#{node['href']}">Read more</a>)
          node.before(node.children).remove
        end
      end

      def other
        @doc = at_css('.guide')

        css('a.toc', '.nav-tabs', '#select-platform', '.guide-controls + .list-group', '.guide-controls').remove

        css('.guide-content', '.tabs', '.tab-content').each do |node|
          node.before(node.children).remove
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
