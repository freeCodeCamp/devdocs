module Docs
  class Less
    class CleanHtmlFilter < Filter
      def call
        css('.source-link').remove

        css('#functions-overview').each do |node|
          node.ancestors('.docs-section').remove
        end

        css('.docs-section', 'blockquote').each do |node|
          node.before(node.children).remove
        end

        css('.page-header').each do |node|
          node.before(node.first_element_child).remove
        end

        css('h1, h2, h3, h4').each do |node|
          node.name = node.name.sub(/\d/) { |i| i.to_i + 1 }
        end

        css('pre').each do |node|
          node.content = node.content
        end

        doc
      end
    end
  end
end
