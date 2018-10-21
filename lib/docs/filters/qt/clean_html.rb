module Docs
  class Qt
    class CleanHtmlFilter < Filter
      def call
        # Remove unneeded elements
        css('.copy-notice, .navigationbar, .headerNavi, .footerNavi, .sidebar, .toc, #ec_toggle', '.landingicons img', 'br').remove

        # QML property/method header
        css('.qmlproto').each do |node|
          id = node.at_css('tr')['id']
          node.inner_html = node.at_css('td').inner_html
          node.name = 'h3'
          node['id'] = id
        end

        css('.main-rounded', '.content', '.line', '.context', '.descr', '.types', '.func', '.table', 'div:not([class])', '.landing', '.col-1', '.heading', '.qmlitem', '.qmldoc', 'div.pre').each do |node|
          node.before(node.children).remove
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
