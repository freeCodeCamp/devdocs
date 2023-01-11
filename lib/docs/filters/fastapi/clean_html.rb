module Docs
  class Fastapi
    class CleanHtmlFilter < Filter

      def call
        doc.css('.headerlink').remove

        if root_page?
          doc.css('#sponsors ~ p', '#sponsors').remove
        end

        doc.css('.tabbed-set').each do |node|
          labels = node.css('.tabbed-labels label')
          blocks = node.css('.tabbed-content .tabbed-block')

          blocks.each_with_index do |block_node, i|
            block_node.prepend_child(labels[i]) if labels[i]
          end

          node.css('> input, .tabbed-labels').remove
        end

        doc.css('pre').each do |node|
          node['class'] = "language-python"
          node['data-language'] = "python"
          node.content = node.at_css('code').content
        end

        doc
      end

    end
  end
end
