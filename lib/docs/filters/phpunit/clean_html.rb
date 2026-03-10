module Docs
  class Phpunit
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('section') if not root_page?

        css('pre').each do |node|
          node['class'] = 'highlight'
          node['data-language'] = 'php'
        end

        # When extracting strings, filter out non-ASCII chars that mysteriously get added.

        if slug.match(/assertion|annotations|configuration/)
          css('h2').each do |node|
            node['id'] = node.content.gsub(/\P{ASCII}/, '')
          end
        end

        css('h1', 'h2', 'h3').each do |node|
          node.content = node.content.gsub(/\d*\. |\P{ASCII}/, '')
        end

        doc
      end
    end
  end
end
