module Docs
  class Socketio
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('article')

        css('p > br').each do |node|
          node.remove unless node.next.content =~ /\s*\-/
        end

        # version documentation message
        at_css('.warning').remove

        css('header', 'footer', 'aside').remove

        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = node.content =~ /\A\s*</ ? 'html' : 'javascript'
        end

        doc
      end
    end
  end
end
