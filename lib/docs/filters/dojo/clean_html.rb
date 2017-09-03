module Docs
  class Dojo
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          doc.inner_html = ' '
          return doc
        end

        css('h1[class]').each do |node|
          node.remove_attribute('class')
        end

        css('.version', '.jsdoc-permalink', '.feedback', '.jsdoc-summary-heading', '.jsdoc-summary-list', '.jsdoc-field.private').remove

        css('.jsdoc-wrapper, .jsdoc-children, .jsdoc-fields, .jsdoc-field, .jsdoc-property-list, .jsdoc-full-summary, .jsdoc-return-description').each do |node|
          node.before(node.children).remove
        end

        css('a[name]').each do |node|
          next unless node.content.blank?
          node.parent['id'] = node['name']
          node.remove
        end

        css('div.returnsInfo', 'div.jsdoc-inheritance').each do |node|
          node.name = 'p'
        end

        css('div.jsdoc-title').each do |node|
          node.name = 'h3'
        end

        css('.returns').each do |node|
          node.inner_html = node.inner_html + ' '
        end

        css('.functionIcon a').each do |node|
          node.replace(node.content)
        end

        css('.functionIcon', '.parameters').each do |node|
          node.name = 'code'
          node.content = node.content.strip
        end

        css('pre').each do |node|
          node['data-language'] = node.content =~ /\A\s*</ ? 'markup' : 'javascript'
        end

        css('.jsdoc-function-information', '.jsdoc-examples', '.jsdoc-example', 'span').each do |node|
          node.before(node.children).remove
        end

        css('table', 'a', 'h2', 'h3', 'td', 'strong').remove_attr('class')

        doc
      end
    end
  end
end
