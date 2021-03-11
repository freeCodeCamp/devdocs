module Docs
  class Socketio
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('article')

        css('p > br').each do |node|
          node.remove unless node.next.content =~ /\s*\-/
        end

        # version documentation message
        css('.warning').remove

        css('header', 'footer', 'aside').remove

        css('pre').each do |node|
          if node.at_css('.line').nil?
            node.content = node.content
          else
            node.content = node.css('.line').map(&:content).join("\n")
          end
          node['data-language'] = node.content =~ /\A\s*</ ? 'html' : 'javascript'
        end

        doc
      end
    end
  end
end
