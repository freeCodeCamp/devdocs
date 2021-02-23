module Docs
  class ReactBootstrap
    class CleanHtmlFilter < Filter
      def call
        css('.flex-column.d-flex').remove
        css('header').remove
        css('.bs-example').remove

        css('.position-relative pre').each do |node|
          # node.content = node.content
          node.remove_attribute('style')
          node['data-language'] = 'jsx'
          node.parent.replace(node)
        end

        css('div, main, pre, h1, h2, h3, h4, h5, h6, a, p').each do |node|
          node.delete 'class'
        end

        css('#___gatsby, #gatsby-focus-wrapper').each do |node|
          node.delete 'id'
        end
        doc
      end
    end
  end
end
