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

      BROWSER_UNNECESSARY_CLASS_REGEX = /\s*bc-browser[\w_-]+/

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
        css('h2 > a, h3 > a').each do |node|
          node.parent.content = node.content
        end

        css('.notecard > h4').each do |node|
          node.name = 'strong'
        end

        css('svg.deprecated').each do |node|
          node.name = 'span'
          node.content = node.content
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

        # New compatibility tables
        # FIXME(2021):
        # - fetched from external JSON: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/alignment-baseline/bcd.json
        # - https://github.com/mdn/yari/blob/master/build/bcd-urls.js

        css('.bc-data #Legend + dl', '.bc-data #Legend', '.bc-data #Legend_2 + dl', '.bc-data #Legend_2', '.bc-browser-name').remove

        css('abbr.only-icon[title="Full support"]',
            'abbr.only-icon[title="Partial support"]',
            'abbr.only-icon[title="No support"]',
            'abbr.only-icon[title="See implementation notes"]').remove

        css('.bc-data .ic-altname', '.bc-data .ic-deprecated', '.bc-data .ic-non-standard', '.bc-data .ic-experimental').each do |node|
          node.parent.remove
        end

        css('abbr.only-icon').each do |node|
          node.replace(node.content)
        end

        css('.bc-table .bc-platforms td', '.bc-table .bc-browsers td').each do |node|
          node.name = 'th'
        end

        css('.bc-data').each do |node|
          link = node.at_css('.bc-github-link')
          prev = node.previous_element
          prev = prev.previous_element until prev.name == 'h2'
          prev.add_child(link)

          node.before(node.children).remove
        end

        css('.bc-table').each do |node|
          desktop_table = node

          mobile_table = node.dup
          desktop_table.after(mobile_table)

          if desktop_table.at_css('.bc-platform-server')
            server_table = node.dup
            mobile_table.after(server_table)
          end

          desktop_columns = desktop_table.at_css('th.bc-platform-desktop')['colspan'].to_i
          mobile_columns = desktop_table.at_css('th.bc-platform-mobile')['colspan'].to_i

          desktop_table.css('.bc-platform-mobile').remove
          desktop_table.css('.bc-platform-server').remove
          desktop_table.css('.bc-browsers th').to_a[(desktop_columns + 1)..-1].each(&:remove)
          desktop_table.css('tr:not(.bc-platforms):not(.bc-browsers)').each do |line|
            line.css('td').to_a[(desktop_columns)..-1].each(&:remove)
          end

          mobile_table.css('.bc-platform-desktop').remove
          mobile_table.css('.bc-platform-server').remove
          mobile_table.css('.bc-browsers th').to_a[1..(desktop_columns)].each(&:remove)
          mobile_table.css('.bc-browsers th').to_a[(mobile_columns + 1)..-1].each(&:remove)
          mobile_table.css('tr:not(.bc-platforms):not(.bc-browsers)').each do |line|
            line.css('td').to_a[0..(desktop_columns - 1)].each(&:remove)
            line.css('td').to_a[(mobile_columns)..-1].each(&:remove)
          end

          if server_table
            server_table.css('.bc-platform-desktop').remove
            server_table.css('.bc-platform-mobile').remove
            server_table.css('.bc-browsers th').to_a[1..(desktop_columns + mobile_columns)].each(&:remove)
            server_table.css('tr:not(.bc-platforms):not(.bc-browsers)').each do |line|
              line.css('td').to_a[0..(desktop_columns + mobile_columns - 1)].each(&:remove)
            end
          end
        end

        # Reduce page size to make the offline bundle smaller.
        css('.bc-supports-unknown').remove_attr('class')
        css('td[class*="bc-platform"], th[class*="bc-platform"]').remove_attr('class')
        css('td[class*="bc-browser"], th[class*="bc-browser"]').each do |node|
          class_name = node['class']
          class_name.remove!(BROWSER_UNNECESSARY_CLASS_REGEX)

          if class_name.present?
            node['class'] = class_name
          else
            node.remove_attribute('class')
          end
        end

        css('abbr[title*="Compatibility unknown"]').each do |node|
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
