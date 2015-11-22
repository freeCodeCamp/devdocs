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

        doc
      end
    end
  end
end
