module Docs
  class Vulkan
    class CleanHtmlFilter < Filter
      def call
        at_css('#_copyright').parent.remove

        css('.sect1', '.sectionbody', '.sect2', '.sect3', 'div.paragraph', 'li > p:only-child', 'dd > p:only-child', 'span', '.ulist').each do |node|
          node.before(node.children).remove
        end

        css('a[id]:empty').each do |node|
          node.parent['id'] ||= node['id']
          node.remove
        end

        css('.listingblock').each do |node|
          node['data-language'] = node.at_css('[data-lang]')['data-lang']
          node.content = node.content.strip
          node.name = 'pre'
          node.remove_attribute('class')
        end

        css('.sidebarblock').each do |node|
          node.name = 'blockquote'
          node.at_css('.title').name = 'h5'
          node.css('div').each { |n| n.before(n.children).remove }
          node.remove_attribute('class')
        end

        css('.admonitionblock').each do |node|
          node.name = 'blockquote'
          node.children = node.at_css('.content').children
          node.at_css('.title').name = 'h5'
          node.remove_attribute('class')
        end

        css('table').each do |node|
          node.before %(<div class="_table"></div>)
          node.previous_element << node
        end

        css('strong', 'dt', 'a').remove_attr('class')

        css('h4 + h4').each do |node|
          node.previous_element.remove
        end

        css('p:contains("This page is extracted from the Vulkan Specification. Fixes and changes should be made to the Specification, not directly.")').remove

        doc
      end
    end
  end
end
