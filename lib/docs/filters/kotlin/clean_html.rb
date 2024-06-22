module Docs
  class Kotlin
    class CleanHtmlFilter < Filter
      def call
        subpath.start_with?('api') ? api_page : doc_page
        doc
      end

      def doc_page
        css('.page-link-to-github').remove

        css('a > img').each do |node|
          node.parent.before(node.parent.content).remove
        end
      end

      def api_page
        at_css('h1, h2, h3').name = 'h1'

        if breadcrumbs = at_css('.api-docs-breadcrumbs')
          at_css('h1').after(breadcrumbs)
        end

        unless at_css('h2')
          css('h3').each do |node|
            node.name = 'h2'
          end
        end

        css('a[href="#"]').each do |node|
          node.before(node.content).remove
        end

        css('.signature > code').each do |node|
          parent = node.parent
          parent.name = 'pre'
          parent.inner_html = node.inner_html.gsub('<br>', "\n").strip
          parent.content = parent.content
          parent['data-language'] = 'kotlin'
        end

        css('.tags').each do |wrapper|
          platforms = wrapper.css('.platform:not(.tag-value-Common)').to_a
          platforms = platforms.map { |node| "#{node.content} (#{node['data-tag-version']})" }
          platforms = "<b>Platform and version requirements:</b> #{platforms.join ", "}"
          wrapper.replace(platforms)
        end
      end
    end
  end
end
