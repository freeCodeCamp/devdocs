module Docs
  class Socketio
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.entry-content')

        css('p > br').each do |node|
          node.remove unless node.next.content =~ /\s*\-/
        end

        css('h1, h2, h3').each do |node|
          next if node == doc.first_element_child
          node.name = node.name.sub(/\d/) { |i| i.to_i + 1 }
          node['id'] = node.content.strip.parameterize
        end

        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = node.content =~ /\A\s*</ ? 'html' : 'javascript'
        end

        doc
      end
    end
  end
end
