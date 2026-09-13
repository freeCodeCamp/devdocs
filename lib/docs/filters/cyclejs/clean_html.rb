module Docs
  class Cyclejs
    class CleanHtmlFilter < Filter
      def call
        return "<h1>Cycle.js</h1><p>A functional and reactive JavaScript framework for predictable code</p>" if root_page?
        css('br').remove

        css('pre > code').each do |node|
          parent = node.parent
          parent['data-language'] = 'javascript'
          parent.content = node.content.strip
        end

        css('table[style]', 'tr[style]', 'td[style]', 'th[style]').remove_attr('style')
        css('img').each do |node|
          node['alt'] = node['alt'].presence || ''
        end

        doc
      end
    end
  end
end
