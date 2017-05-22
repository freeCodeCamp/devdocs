module Docs
  class Cordova
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.page-content > div')

        at_css('h1').content = 'Apache Cordova' if root_page?

        css('hr', '.content-header', 'button', '.docs-alert').remove

        css('.home', '#page-toc-source', '.highlight', 'th h2').each do |node|
          node.before(node.children).remove
        end

        css('img[src*="travis-ci"]').each do |node|
          node.ancestors('p, a').first.remove
        end

        css('pre').each do |node|
          node['data-language'] = node.at_css('code')['data-lang']
          node.content = node.content.strip_heredoc
        end

        css('> .alert + h1').each do |node|
          node.previous_element.before(node)
        end

        css('h1, h2, h3, h4, h5, h6').each do |node|
          node['id'] = node.content.strip.parameterize
        end

        css('> table:first-child + h1').each do |node|
          node.previous_element.remove
        end

        doc
      end
    end
  end
end
