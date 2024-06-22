module Docs
  class React
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('article')

        if root_page?
          at_css('h1').content = 'React Documentation'
        end

        css('header', 'div[class^="css-"]', '.gatsby-resp-image-link span', 'div.scary').each do |node|
          node.before(node.children).remove
        end

        css('.gatsby-highlight > pre').each do |node|
          node.content = node.at_css('code').children.map do |n|
            if !n['class'].nil? && n['class'][/gatsby-highlight-code-line/]
              n.content + "\n"
            else
              n.content
            end
          end.join("")
          node['data-language'] = node['class'][/(?<=gatsby\-code\-)(\w+)/]
          node.remove_attribute('class')
          node.parent.replace(node)
        end

        css('a.anchor', 'a:contains("Edit this page")', 'hr').remove

        css('a').remove_attr('rel').remove_attr('target').remove_attr('class').remove_attr('style')
        css('img').remove_attr('style').remove_attr('srcset').remove_attr('sizes').remove_attr('class')

        css('[class*="css-"]').each do |node|
          node['class'] = node['class'].sub(/css-[^ ]+(\b|$)/, '')
          node.delete 'class' if node['class'] == ''
        end

        doc
      end
    end
  end
end
