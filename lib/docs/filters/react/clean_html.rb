module Docs
  class React
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('article')

        if root_page?
          at_css('h1').content = 'React Documentation'
        end

        css('header', 'div[class^="css-"]', '.gatsby-resp-image-link span').each do |node|
          node.before(node.children).remove
        end

        css('.gatsby-highlight > pre').each do |node|
          node.content = node.content
          node['data-language'] = node['class'][/(?<=gatsby\-code\-)(\w+)/]
          node.remove_attribute('class')
          node.parent.replace(node)
        end

        css('a.anchor', 'a:contains("Edit this page")', 'hr').remove

        css('a').remove_attr('rel').remove_attr('target').remove_attr('class').remove_attr('style')
        css('img').remove_attr('style').remove_attr('srcset').remove_attr('sizes').remove_attr('class')

        doc
      end
    end
  end
end
