module Docs
  class Cyclejs
    class CleanHtmlFilter < Filter
      def call
        css('br').remove

        css('pre > code').each do |node|
          parent = node.parent
          if node['class'] && node['class'] =~ /language-(\w+)/
            parent['data-language'] = Regexp.last_match(1)
          end
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
