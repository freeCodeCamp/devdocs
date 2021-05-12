module Docs
  class Node
    class CleanHtmlFilter < Filter
      def call
        css('hr').remove

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

          if lang = node.at_css('code')['class']
            node['data-language'] = lang.remove(%r{lang(uage)?-})
          end

          node.content = node.content
        end

        css('h3 > code, h4 > code, h5 > code').each do |node|
          tmp = node.content
          has_parethesis = true if tmp =~ /\(/
          tmp.gsub!(/\(.*\)/, '')

          if has_parethesis
            tmp << '()'
          end

          node.parent['id'] = tmp

        end

        doc
      end
    end
  end
end
