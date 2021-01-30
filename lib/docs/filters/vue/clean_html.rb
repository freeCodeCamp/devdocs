module Docs
  class Vue
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css(version == '3' ? 'main' : '.content')

        at_css('h1').content = 'Vue.js' if root_page?
        doc.child.before('<h1>Vue.js API</h1>') if slug == 'api/' || slug == 'api/index'

        css('.demo', '.guide-links', '.footer', '#ad').remove
        css('.header-anchor', '.page-edit', '.page-nav').remove

        css('.custom-block-title').each do |node|
          node.name = 'strong'
        end

        # Remove code highlighting
        css('figure').each do |node|
          node.name = 'pre'
          node.content = node.at_css('td.code pre').css('.line').map(&:content).join("\n")
          node['data-language'] = node['class'][/highlight (\w+)/, 1]
        end

        css('.line-numbers-wrapper').remove
        css('pre').each do |node|
          node.content = node.content.strip
          node['data-language'] = 'javascript'
        end

        css('iframe').each do |node|
          node['sandbox'] = 'allow-forms allow-scripts allow-same-origin'
          node.remove if node['src'][/player.vimeo.com/] # https://v3.vuejs.org/guide/migration/introduction.html#overview
        end

        css('details').each do |node|
          node.name = 'div'
        end

        doc
      end
    end
  end
end
