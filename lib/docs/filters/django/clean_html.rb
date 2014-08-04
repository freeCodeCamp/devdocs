module Docs
  class Django
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.yui-g')

        css('.section', 'a > em').each do |node|
          node.before(node.children).remove
        end

        css('tt', 'span.pre').each do |node|
          node.name = 'code'
          node.content = node.content
          node.remove_attribute 'class'
        end

        css('.headerlink').each do |node|
          id = node['href'][1..-1]
          node.parent['id'] ||= id
          doc.at_css("span##{id}").try(:remove)
          node.remove
        end

        css('h1', 'h2', 'h3', 'dt').each do |node|
          node.content = node.content
        end

        css('div[class^="highlight-"]').each do |node|
          node.name = 'pre'
          node['class'] = case node['class']
            when 'highlight-python' then 'python'
            when 'highlight-html+django' then 'markup'
            else ''
          end
          node.content = node.at_css('pre').content
        end

        doc
      end
    end
  end
end
