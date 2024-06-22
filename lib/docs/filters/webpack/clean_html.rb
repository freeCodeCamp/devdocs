module Docs
  class Webpack
    class CleanHtmlFilter < Filter
      def call
        at_css('h1').content = 'webpack' if root_page?

        css('hr', '.page__edit', 'hr + h3:contains("Contributors")', 'hr + h2:contains("Contributors")',
            'td > .title', '.adjacent-links', '.contributors', '.icon-link',
            '#maintainers', '#maintainers + table',
            '#maintainer', '#maintainer + table',
            '.page-links__link', '.page-links__gap').remove

        css('> div', '.tip-content', '.header span').each do |node|
          node.before(node.children).remove
        end

        css('pre > code').each do |node|
          node.parent['data-language'] = 'js'
          node.parent['data-language'] = node['class'][/language-(\w+)/, 1].sub('jsx', 'js') if node['class'] && node['class'][/language-(\w+)/, 1]
          node.parent.content = node.parent.content
        end

        css('*').each do |node|
          node.remove if node['class'] && node['class'][/print:hidden/]
        end

        # for webpack-contrib /loaders and /plugins
        shields = at_css('img[src*="shields.io"]')
        shields.ancestors('p')[0].remove if shields

        doc
      end
    end
  end
end
