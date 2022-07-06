module Docs
  class Padrino
    class CleanHtmlFilter < Filter
      def call
        css('.summary_toggle', '.inheritanceTree', 'h1 .note', '.source_code', '.box_info dl:last-child').remove
        css('a[href*="travis"]', 'a[href*="gemnasium"]', 'a[href*="codeclimate"]', 'a[href*="gitter"]').remove if root_page?

        css('.signature').each do |node|
          node.name = 'h3'
        end

        css('.permalink', 'div.docstring', 'div.discussion', '.method_details_list', '.attr_details',
            'h3 strong', 'h3 a', 'h3 tt', 'h3 span', 'div.inline p', 'div.inline').each do |node|
          node.before(node.children).remove
        end

        css('.tag_title').each do |node|
          node.name = 'h4'
        end

        css('span.summary_signature', 'tt', '.tags span.name').each do |node|
          node.name = 'code'
          node.inner_html = node.inner_html.strip
        end

        css('code > a').each do |node|
          node.inner_html = node.inner_html.strip
        end

        css('pre.code').each do |node|
          node.content = node.content
          node['data-language'] = 'ruby'
        end

        doc
      end
    end
  end
end
