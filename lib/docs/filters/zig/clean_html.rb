module Docs
  class Zig
    class CleanHtmlFilter < Filter
      def call
        at_css('main').prepend_child at_css('h1')
        @doc = at_css('main')
        css('a.hdr').remove
        css('h1, h2, h3').each do |node|
          node.content = node.content
        end
        css('pre > code').each do |node|
          node.parent['data-language'] = 'zig'
          node.parent.content = node.parent.content
        end
        doc
      end
    end
  end
end
