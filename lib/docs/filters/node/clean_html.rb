module Docs
  class Node
    class CleanHtmlFilter < Filter
      def call
        css('hr').remove

        css('pre').each do |node|
          next unless (node.css('code').to_a.length > 1)

          node.css('code').each do |subnode|
            node.before(subnode)

            if subnode.classes.include?('mjs')
              subnode.wrap('<details open>')
              subnode.wrap('<pre>')
              subnode.ancestors('details').first.prepend_child('<summary>JavaScript modules</summary>')
            elsif subnode.classes.include?('cjs')
              subnode.wrap('<details>')
              subnode.wrap('<pre>')
              subnode.ancestors('details').first.prepend_child('<summary>CommonJS</summary>')
            end
          end

          node.remove
        end

        # Remove "#" links
        css('.mark').each do |node|
          node.parent.parent['id'] = node['id']
          node.parent.remove
        end

        css('pre[class*="api_stability"]').each do |node|
          node.name = 'div'
        end

        css('pre').each do |node|
          next unless node.at_css('code')

          node['data-language'] = 'js'

          node.content = node.content
        end

        doc
      end
    end
  end
end
