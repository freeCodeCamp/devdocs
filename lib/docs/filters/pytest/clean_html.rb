module Docs
  class Pytest
    class CleanHtmlFilter < Filter
      def call
        # Removed here rather than by sphinx/clean_html because the entries
        # filter reads the headings' text content
        css('.headerlink').remove

        # "[source]" links pointing to the highlighted sources, which aren't scraped
        css('.viewcode-link').each do |node|
          node.parent.remove
        end

        # Tab sets (e.g. the configuration file formats) are made of hidden radio
        # inputs and labels, which don't work without the theme's stylesheet. The
        # tabs are turned into consecutive sections instead.
        css('.tab-input').remove

        css('.tab-label').each do |node|
          node.name = 'h4'
          node.remove_attribute('class')
          node.remove_attribute('for')
        end

        css('.tab-content', '.tab-set').each do |node|
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
