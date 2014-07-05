module Docs
  class Cordova
    class CleanHtmlFilter < Filter
      def call
        if root_page? || slug == 'cordova_events_events.md'
          css('h1, h2').each do |node|
            node.name = node.name.sub(/\d/) { |i| i.to_i + 1 }
          end
          at_css('h2').name = 'h1' if slug == 'cordova_events_events.md'
        end

        if root_page?
          css('li > h3').each do |node|
            node.name = 'div'
          end
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
