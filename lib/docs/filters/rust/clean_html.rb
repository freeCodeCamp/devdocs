module Docs
  class Rust
    class CleanHtmlFilter < Filter
      def call
        if slug.start_with?('book')
          book
        elsif slug.start_with?('reference') || slug == 'error-index'
          reference
        else
          api
        end

        css('.rusttest', 'hr').remove

        css('.docblock > h1').each { |node| node.name = 'h4' }
        css('h2.section-header').each { |node| node.name = 'h3' }
        css('h1.section-header').each { |node| node.name = 'h2' }

        css('> .impl-items', '> .docblock').each do |node|
          node.before(node.children).remove
        end

        css('h1 > a', 'h2 > a', 'h3 > a', 'h4 > a', 'h5 > a').each do |node|
          node.before(node.children).remove
        end

        css('pre > code').each do |node|
          node.parent['class'] = node['class']
          node.before(node.children).remove
        end

        css('pre').each do |node|
          node.content = node.content
        end

        doc
      end

      def book
        @doc = at_css('#page')
      end

      def reference
        css('#versioninfo', '.error-undescribed').remove

        css('.error-described').each do |node|
          node.before(node.children).remove
        end
      end

      def api
        @doc = at_css('#main')

        css('.toggle-wrapper').remove

        css('h1.fqn').each do |node|
          node.content = node.at_css('.in-band').content
        end

        css('.stability .stab').each do |node|
          node.name = 'span'
          node.content = node.content
        end
      end
    end
  end
end
