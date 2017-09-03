module Docs
  class Webpack
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.page__content')

        at_css('h1').content = 'webpack' if root_page?

        css('h3').each do |node|
          node.name = 'h2'
        end unless at_css('h2')

        css('.anchor[id]').each do |node|
          node.parent['id'] = node['id']
          node.remove
        end

        css('hr', '.page__edit', 'hr + h3:contains("Contributors")', 'hr + h2:contains("Contributors")',
            '.contributors', '.icon-link', '#maintainers.header', '#maintainers.header + table',
            '#maintainer.header', '#maintainer.header + table', '.page-links__link', '.page-links__gap').remove

        css('> div', '.tip-content', '.header span').each do |node|
          node.before(node.children).remove
        end

        css('> h1:first-child + h1').remove

        css('.code-details-summary-span').each do |node|
          node.content = node.content.remove(' (click to show)')
        end

        css('.table-wrap').each do |node|
          css('.table-td-title').remove
          css('.table-th').each { |n| n.name = 'th' }
          css('.table-td').each { |n| n.name = 'td' }
          css('.table-tr').each { |n| n.name = 'tr' }
          css('.table-body').each { |n| n.name = 'tbody' }
          css('.table-header').each { |n| n.name = 'thead' }
          node.name = 'table'
        end

        css('pre > code').each do |node|
          node.parent['data-language'] = node['class'][/lang-(\w+)/, 1].sub('jsx', 'js') if node['class']
          node.parent.content = node.parent.content
        end

        doc
      end
    end
  end
end
