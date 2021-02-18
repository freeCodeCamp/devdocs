module Docs
  class Crystal
    class CleanHtmlFilter < Filter
      def call
        slug.start_with?('reference') ? book : api
        doc
      end

      def book
        @doc = at_css('main article')

        css('.headerlink').remove

        css('pre > code').each do |node|
          node.parent['data-language'] = 'crystal'
          node.parent['data-language'] = node['class'][/lang-(\w+)/, 1] if node['class']
          node.parent.content = node.parent.content
        end
      end

      def api
        @doc = at_css('.main-content')

        at_css('h1 + p').remove if root_page?

        css('.method-permalink', '.doc + br', 'hr', 'a > br', 'div + br').remove

        css('pre > code').each do |node|
          node.parent['data-language'] = 'crystal'
          node.parent.content = node.parent.content
        end

        css('span').each do |node|
          node.before(node.children).remove
        end

        css('div.signature').each do |node|
          node.name = 'h3'
          node.inner_html = node.inner_html.strip
        end

        css('.entry-detail a:contains("View source")').each do |node|
          node['class'] = 'view-source'
          node.content = 'Source'
          parent = node.parent
          node.ancestors('.entry-detail').first.at_css('h3') << node
          parent.remove
        end
      end
    end
  end
end
