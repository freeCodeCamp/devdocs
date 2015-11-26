module Docs
  class Cakephp
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          css('.section').remove
        end

        css('.breadcrumbs', '.info', 'a.permalink').remove

        css('h1').drop(1).each do |node|
          node.name = 'h2'
        end

        css('.property-name').each do |node|
          node.name = 'h3'
        end

        # Move dummy anchor to method and property name
        css('.method-detail').each do |node|
          node.at_css('.method-name')['id'] = node.at_css('a')['id']
        end
        css('.property-detail').each do |node|
          node.at_css('.property-name')['id'] = node['id']
          node.remove_attribute('id')
        end

        # Break out source link to separate element
        css('.method-name', '.property-name').each do |node|
          source = node.at_css('a')
          source.add_previous_sibling("<span class=\"name\">#{source.content}</span>")
          source.content = 'source'
        end

        # These are missing in upstream documentation. Not sure why.
        css('.section > h2').each do |node|
          if node.content == "Method Detail"
            node['id'] = 'methods'
          end
          if node.content == 'Properties summary'
            node['id'] = 'properties'
          end
        end

        css('.method-signature').each do |node|
          node.name = 'pre'
          node.content = node.content.strip
        end

        css('span.name > code').each do |node|
          node.content = node.content.strip
        end

        # Pages don't share a nice common base css tag.
        doc.children
      end
    end
  end
end
