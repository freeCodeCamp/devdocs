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

        # Prepend links with 'R.'
        css('h2 > a.name, .see a').each do |link|
          link.content = 'R.' + link.content
        end

        css('.params').each do |node|
          # Remove params expand link
          node.inner_html = node.at_css('.details').inner_html
          node.prepend_child "<h4>Parameters</h4>"

          # Count params
          if ul = node.at_css('ul')
            ul.name = 'ol'
          end

          # change param names to <code>
          node.css('span.name').each do |n|
            n.name = 'code'
            n.remove_attribute 'class'
          end

          # change returns to <h4> to make consistant look with params header
          if returns = node.at_css('span.returns')
            returns.name = 'h4'
          end
        end

        # Remove code highlighting
        css('pre').each do |node|
          node.content = node.content
        end

        doc
      end
    end
  end
end
