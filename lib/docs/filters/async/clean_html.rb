module Docs
  class Async
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#main-container')

        at_css('footer').remove

        css('section', 'header', 'article', '.container-overview', 'span.signature', 'div.description').each do |node|
          node.before(node.children).remove
        end

        css('h3', 'h4', 'h5').each do |node|
          node.name = node.name.sub(/\d/) { |i| i.to_i - 1 }
        end

        css('dd ul').each do |node|
          node.replace(node.css('li').map(&:inner_html).join(' '))
        end

        css('pre').each do |node|
          node['data-language'] = 'javascript'
          node.content = node.content
        end

        doc
      end
    end
  end
end
