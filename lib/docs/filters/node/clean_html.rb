module Docs
  class Node
    class CleanHtmlFilter < Filter
      def call
        css('hr').remove

        css('pre').each do |node|
          next unless (node.css('code').to_a.length > 1)

          node.css('code').each do |subnode|

            if subnode.classes.include?('mjs')
              node.before('<p class=module-type>MJS modules</p>')
            elsif subnode.classes.include?('cjs')
              node.before('<p class=module-type>CJS modules</p>')
            end

            node.before(subnode)
            subnode.wrap('<pre>')
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
