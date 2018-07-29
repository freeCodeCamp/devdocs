module Docs
  class Qt
    class CleanHtmlFilter < Filter
      def call
        # Remove unneeded elements
        css('.copy-notice, .navigationbar, .headerNavi, .footerNavi, .sidebar, .toc, #ec_toggle').remove

        # QML property/method header
        css('.qmlproto').each do |node|
          id = node.at_css('tr')['id']
          node.inner_html = node.at_css('td').inner_html
          node.name = 'h3'
          node.add_class '_qml_header'
          node['id'] = id
        end

        doc
      end
    end
  end
end
