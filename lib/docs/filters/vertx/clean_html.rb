module Docs
  class Vertx
    class CleanHtmlFilter < Filter
      def call
        css('hr', 'header', 'nav', '.navbar', '.topbar').remove
        xpath('//*[@id="docs-layout"]/div/div[3]').remove
        xpath('//*[@id="docs-layout"]/div/div[1]').remove
        xpath('//main/div[last()]').remove
        xpath('//main/div[1]').remove
        xpath('//footer').remove
        css('#changelog').remove if root_page?

        # Set id attributes on <h3> instead of an empty <a>
        css('h3').each do |node|
          anchor = node.at_css('a')
          node['id'] = anchor['id'] if anchor && anchor['id']
        end

        # Make proper table headers
        css('td.header').each do |node|
          node.name = 'th'
        end

        # Remove code highlighting
        css('pre').each do |node|
          node.content = node.content
        end

        # ❗ Skip <img> tags with data: URIs
        css('img').each do |img|
          src = img['src']
          img.remove if src&.start_with?('data:')
        end

        doc
      end
    end
  end
end

