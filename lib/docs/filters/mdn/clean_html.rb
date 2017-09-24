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
        '.communitybox',
        '#Quick_Links',
        'hr']

      def call
        css(*REMOVE_NODES).remove

        css('td.header').each do |node|
          node.name = 'th'
        end

        css('nobr', 'span[style*="font"]', 'pre code', 'h2 strong', 'div:not([class])', 'span.seoSummary').each do |node|
          node.before(node.children).remove
        end

        css('h2[style]', 'pre[style]', 'th[style]', 'div[style*="line-height"]', 'table[style]', 'pre p[style]').remove_attr('style')

        css('strong > code:only-child').each do |node|
          node.parent.before(node).remove
        end

        css('a[title]', 'span[title]').remove_attr('title')
        css('a.glossaryLink', 'a.external').remove_attr('class')
        css('*[lang]').remove_attr('lang')

        css('h2 > a[name]', 'h3 > a[name]').each do |node|
          node.parent['id'] = node['name']
          node.before(node.content).remove
        end

        css('dt > a[id]').each do |node|
          next if node['href']
          node.parent['id'] = node['id']
          node.before(node.children).remove
        end

        css('pre[class^="brush"]').each do |node|
          node['data-language'] = node['class'][/brush: ?(\w+)/, 1]
          node.remove_attribute('class')
        end

        css('pre.eval').each do |node|
          node.content = node.content
          node.remove_attribute('class')
        end

        css('table').each do |node|
          node.before %(<div class="_table"></div>)
          node.previous_element << node
        end

        doc
      end
    end
  end
end
