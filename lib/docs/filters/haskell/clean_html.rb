module Docs
  class Haskell
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
        css('#description', '#module-list').each do |node|
          node.before(node.children).remove
        end
      end

      def other
        css('h1').each do |node|
          node.remove if node.content == 'Documentation'
        end

        css('h1, h2, h3, h4').each do |node|
          node.name = node.name.sub(/\d/) { |i| i.to_i + 1 }
        end

        at_css('#module-header').tap do |node|
          heading = at_css('.caption')
          heading.name = 'h1'
          node.before(heading)
          node.before(node.children).remove
        end

        css('#synopsis').remove

        css('#interface', 'h2 code').each do |node|
          node.before(node.children).remove
        end

        css('a[name]').each do |node|
          node['id'] = node['name']
          node.remove_attribute('name')
        end

        css('p.caption').each do |node|
          node.name = 'h4'
        end

        css('em').each do |node|
          if node.content.start_with?('O(')
            node.name = 'span'
            node['class'] = 'complexity'
          elsif node.content.start_with?('Since')
            node.name = 'span'
            node['class'] = 'version'
          end
        end

        doc
      end
    end
  end
end
