module Docs
  class Relay
    class CleanHtmlFilter < Filter
      def call

        if slug == 'index'
          css('img').remove

          css('.projectTitle').each do |node|
            node.name = 'h1'
            node.content = 'Relay'
          end

          css('pre').remove

        end

        css('.docLastUpdate').remove

        css('.docs-prevnext').remove

        css('.edit-page-link').remove

        css('h2, h3').each do |node|
          node.css('a').remove
          node['id'] = node.content.gsub(/\s/, '-').downcase
        end

        css('.onPageNav').remove

        css('#docsNav').remove

        css('.fixedHeaderContainer').remove

        css('footer').remove

        # syntax highlight
        css('pre').each do |node|
          node['data-language'] = 'javascript'
          node.add_class('highlight')
        end

        doc
      end
    end
  end
end
