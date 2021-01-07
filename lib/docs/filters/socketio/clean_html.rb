module Docs
  class Socketio
    class CleanHtmlFilter < Filter
      def call

        css('p > br').each do |node|
          node.remove unless node.next.content =~ /\s*\-/
        end

        # version documentation message
        css('.warning').remove

        css('header').remove

        css('aside').remove

        css('footer').remove

        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = node.content =~ /\A\s*</ ? 'html' : 'javascript'
        end

        doc
      end
    end
  end
end
