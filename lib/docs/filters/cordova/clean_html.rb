module Docs
  class Cordova
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          css('h1').each { |node| node.name = 'h2' }
          css('li > h2').each { |node| node.name = 'div' }
        end

        css('hr').remove

        css('a[name]').each do |node|
          node.parent['id'] = node['name']
          node.before(node.children).remove
        end

        # Remove code highlighting
        css('pre').each do |node|
          node.content = node.content.remove(/^\ {4,5}/)
        end

        doc
      end
    end
  end
end
