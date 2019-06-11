module Docs
  class Codeception
    class CleanHtmlFilter < Filter
      def call
        @doc = doc.at_css('#page')

        css('.algolia__search-content').remove

        css('.algolia__initial-content').each do |node|
          node.before(node.children).remove
        end

        while doc.element_children.length == 1
          doc.first_element_child.before(doc.first_element_child.children).remove
        end

        if root_page?
          at_css('h1').content = 'Codeception Documentation'
        end

        unless at_css('h1')
          at_css('h2').name = 'h1'
        end

        unless at_css('h2')
          css('h3').each { |node| node.name = 'h2' }
          css('h4').each { |node| node.name = 'h3' }
        end

        css('.btn-group').remove

        css('.alert:last-child').each do |node|
          node.remove if node.content.include?('taken from the source code')
        end

        css('.highlight').each do |node|
          node.before(node.children).remove
        end

        css('pre > code').each do |node|
          node.parent['data-language'] = node['data-lang']
          node.parent.content = node.parent.content
        end

        doc
      end
    end
  end
end
