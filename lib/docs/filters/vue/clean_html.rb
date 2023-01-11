module Docs
  class Vue
    class CleanHtmlFilter < Filter
      def call
        if current_url.host == 'vitejs.dev'
          return '<h1>Vite</h1>' if root_page?
          @doc = at_css('.content > div')
        else
          return '<h1>Vue.js</h1>' if root_page?
          @doc = at_css(version == '3' ? 'main > div > div' : '.content')
        end

        at_css('h1').content = 'Vue.js' if root_page?
        doc.child.before('<h1>Vue.js API</h1>') if slug == 'api/' || slug == 'api/index'

        css('.demo', '.guide-links', '.footer', '#ad').remove
        css('.header-anchor', '.page-edit', '.page-nav').remove
        css('.next-steps').remove

        css('.custom-block-title').each do |node|
          node.name = 'strong'
        end

        # Remove code highlighting
        css('.line-numbers-wrapper').remove
        css('pre').each do |node|
          node.parent.name = 'pre'
          node.parent['data-language'] = node.parent['class'][/language-(\w+)/, 1]
          node.parent['data-language'] = 'javascript' if node.parent['data-language'][/vue/] # unsupported by prism.js
          node.parent.remove_attribute 'class'
          node.parent.content = node.content.strip
        end

        css('.vue-mastery-link').remove
        css('.vuejobs-wrapper').remove
        css('.vueschool').remove

        css('details').each do |node|
          node.name = 'div'
        end

        doc
      end
    end
  end
end
