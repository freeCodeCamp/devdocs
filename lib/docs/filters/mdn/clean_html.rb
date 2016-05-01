module Docs
  class Mdn
    class CleanHtmlFilter < Filter
      REMOVE_NODES = [
        '#Summary',          # "Summary" heading
        '.htab',             # "Browser compatibility" tabs
        '.breadcrumbs',      # (e.g. CSS/animation)
        '.Quick_links',      # (e.g. CSS/animation)
        '.todo',
        '.draftHeader',
        '.hidden',
        '.button.section-edit',
        'hr']

      def call
        css(*REMOVE_NODES).remove

        css('td.header').each do |node|
          node.name = 'th'
        end

        css('nobr').each do |node|
          node.before(node.children).remove
        end

        css('h2[style]', 'pre[style]', 'th[style]', 'div[style*="line-height"]').remove_attr('style')

        css('h2 > a[name]', 'h3 > a[name]').each do |node|
          node.parent['id'] = node['name']
          node.before(node.content).remove
        end

        doc
      end
    end
  end
end
