module Docs
  class Vue
    class CleanHtmlFilter < Filter
      def call
        return '<h1>Vue.js</h1>' if root_page?
        @doc = at_css(version == '3' ? 'main > div > div' : '.content')

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
        if version == '3'
          css('pre').each do |node|
            node.parent.name = 'pre'
            node.parent['data-language'] = node.parent['class'][/language-(\w+)/, 1]
            node.parent['data-language'] = 'javascript' if node.parent['data-language'][/vue/] # unsupported by prism.js
            node.parent.remove_attribute 'class'
            node.parent.content = node.content.strip
          end
        else
          css('pre').each do |node|
            parent = node.ancestors('figure')[0]
            parent.name = 'pre'
            parent['data-language'] = parent['class'][/(html|js)/, 1]
            parent.remove_attribute 'class'
            node.css('br').each{ |br| br.replace "\n" }
            parent.content = node.content.strip
          end
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
