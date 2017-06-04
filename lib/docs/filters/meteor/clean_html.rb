module Docs
  class Meteor
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.content-wrapper')

        at_css('h1').content = 'Meteor Documentation' if root_page?

        css('.page-actions', '.anchor').remove

        css('.header-content', '.document-formatting', 'h2 > a', '.api', '.api-body', 'div.desc').each do |node|
          node.before(node.children).remove
        end

        css('.anchor-offset').each do |node|
          node.parent['id'] = node['id']
          node.remove
        end

        css('.api-heading').each do |node|
          heading = node.at_css('h2, h3')
          name = heading.name
          node['id'] = heading['id']
          heading.replace "<code>#{heading.content.strip}</code>"
          node.name = name
        end

        css('div.code', 'span.code', '.args .name').each do |node|
          node.name = 'code'
          node.remove_attribute('class')
        end

        css('figure.highlight').each do |node|
          node.inner_html = node.at_css('.code pre').inner_html.gsub('</div><div', "</div>\n<div").gsub('<br>', "\n")
          node.content = node.content
          node['data-language'] = node['class'].split.last
          node.name = 'pre'
        end

        css('pre.prettyprint').each do |node|
          node['data-language'] = node['class'].include?('html') ? 'html' : 'js'
          node.content = node.content
        end

        doc
      end
    end
  end
end
