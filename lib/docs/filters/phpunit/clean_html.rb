module Docs
  class Phpunit
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.section') if not root_page?

        css('pre').each do |node|
          node['class'] = 'highlight'
          node['data-language'] = 'php'
        end

        if slug.match(/assertion|annotations|configuration/)
          css('h2').each do |node|
            node['id'] = node.content
          end
        end

        css('h1').each do |node|
          node.content = node.content.gsub(/\d*\./, '').strip
        end

        doc
      end
    end
  end
end
