module Docs
  class Vite
    class CleanHtmlFilter < Filter
      def call
        return "<h1>Vitest</h1><p>A Vite-native unit test framework. It's fast!</p>" if root_page? && current_url.host == 'vitest.dev'
        return "<h1>VueUse</h1><p>Collection of Vue Composition Utilities</p>" if root_page? && current_url.host == 'vueuse.org'
        return '<h1>Vite</h1><p>Next Generation Frontend Tooling</p>' if root_page?
        @doc = at_css('main h1').parent

        css('.demo', '.guide-links', '.footer', '#ad').remove
        css('.header-anchor', '.page-edit', '.page-nav').remove

        css('.custom-block-title').each do |node|
          node.name = 'strong'
        end

        # Remove CodePen div
        css('.codepen').each do |node|
          raise "dsfsdfsdf"
          next if node.previous_element.nil?
          span = node.css('span:contains("See the Pen")').remove
          node.previous_element.add_child(' ')
          node.previous_element.add_child(span)
          node.remove
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
