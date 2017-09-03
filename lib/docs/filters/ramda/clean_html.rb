module Docs
  class Ramda
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('main')

        # Remove try in repl
        css('.try-repl', '.pull-right').remove

        # Place 'Added in' in header
        css('.card').each do |card|
          title = card.at_css('h2')
          added_in = card.at_css('small')
          added_in.parent = title
        end

        css('.params').each do |node|
          # Remove params expand link
          node.inner_html = node.at_css('.details').inner_html
          node.prepend_child "<h4>Parameters</h4>"

          # change param names to <code>
          node.css('span.name').each do |n|
            n.name = 'code'
          end

          if n = node.at_css('> .panel-body')
            n.before(n.at_css('span.returns').tap { |_n| _n.name = 'h4' })
            n.replace("<ul><li>#{n.to_html}</li></ul>")
          end
        end

        # Remove code highlighting
        css('pre').each do |node|
          node['data-language'] = 'javascript'
          node.content = node.content
        end

        css('div.see').each do |node|
          node.name = 'p'
        end

        css('.see a').each do |node|
          node.replace "<code>#{node.to_html}</code>"
        end

        css('h2 + div > code:only-child').each do |node|
          node.parent.name = 'pre'
          node.parent.content = node.content
        end

        css('.card', '.panel-body', 'div.params', 'div.description', 'h2 > a').each do |node|
          node.before(node.children).remove
        end

        css('.section-id[id]').each do |node|
          node.next_element['id'] = node['id']
          node.remove
        end

        css('h2').each do |node|
          node.name = 'h3'
        end

        doc
      end
    end
  end
end
