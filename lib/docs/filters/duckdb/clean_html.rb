module Docs
  class Duckdb
    class CleanHtmlFilter < Filter
      def call
        # First extract the main content
        @doc = at_css('#main_content_wrap', 'main')
        return doc if @doc.nil?

        doc.prepend_child at_css('.title').remove
        at_css('.title').name = 'h1'

        # Remove navigation and header elements
        css('.headerline', '.headlinebar', '.landingmenu', '.search_icon', '#sidebar', '.pagemeta', '.toc_menu', '.section-nav').remove

        # Clean up code blocks
        css('div.highlighter-rouge').each do |node|
          node['data-language'] = node['class'][/language-(\w+)/, 1] if node['class']
          node.content = node.content.strip
          node.name = 'pre'
        end

        # Remove unnecessary attributes
        css('div, span, p').each do |node|
          node.remove_attribute('style')
          node.remove_attribute('class')
        end

        # Remove empty elements
        css('div, span').each do |node|
          node.remove if node.content.strip.empty?
        end

        # Remove script tags
        css('script').remove

        doc
      end
    end
  end
end