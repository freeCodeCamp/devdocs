module Docs
  class Qt
    class CleanHtmlFilter < Filter
      def call
        # Narrow down container further. Breadcrumb is safe to remove.
        @doc = at_css('article .mainContent .context') unless root_page?

        css('h1').remove_attribute('class')

        # QML property/method header
        css('.qmlproto').each do |node|
          id = node.at_css('span.name').content
          node.inner_html = node.at_css('td').inner_html
          node.name = 'h3'
          node['id'] = id
        end

        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = 'cpp' if node['class'].include?('cpp')
          node['data-language'] = 'qml' if node['class'].include?('qml')
          node.remove_attribute('class')
        end

        doc
      end
    end
  end
end
