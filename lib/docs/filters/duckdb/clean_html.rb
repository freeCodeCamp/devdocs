module Docs
  class Duckdb
    class CleanHtmlFilter < Filter
      def call
        # First extract the main content
        @doc = at_css('main')
        return doc if @doc.nil?

        # Remove navigation and header elements
        css('.headerline', '.landingmenu', '.search_icon', '#sidebar', '.pagemeta', '.toc_menu', '.section-nav').remove

        # Clean up code blocks
        css('pre').each do |node|
          # Detect language from class or parent div
          if node['class']&.include?('sql') || node.at_css('code.sql')
            node['data-language'] = 'sql'
          elsif node['class']&.include?('language-sql')
            node['data-language'] = 'sql'
          end
          node.content = node.content.strip
        end

        # Remove unnecessary attributes but keep essential ones
        css('div, span, p').each do |node|
          node.remove_attribute('style')
          node.remove_attribute('class') unless node['class'] =~ /highlight/
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