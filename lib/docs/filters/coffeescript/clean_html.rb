module Docs
  class Coffeescript
    class CleanHtmlFilter < Filter
      def call
        css('#top', '.minibutton', '.clear').remove

        # Set id attributes on actual elements instead of an empty <span>
        css('.bookmark').each do |node|
          if node.parent.name == 'h2'
            node.parent['id'] = node['id']
          elsif node.next_element.name == 'b'
            node.next_element['id'] = node['id']
          end
          node.remove
        end

        # Remove Books, Screencasts, etc.
        while doc.children.last['id'] != 'scripts'
          doc.children.last.remove
        end
        doc.children.last.remove

        # Make proper headings
        css('.header').each do |node|
          node.parent.before(node)
          node.name = 'h3'
          node['id'] ||= node.content.strip.parameterize
          node.remove_attribute 'class'
        end

        # Remove "Latest Version" paragraph
        css('b').each do |node|
          if node.content =~ /Latest Version/i
            node.parent.next_element.remove
            node.parent.remove
            break
          end
        end

        # Remove "examples can be run" paragraph
        css('i').each do |node|
          if node.content =~ /examples can be run/i
            node.parent.remove
            break
          end
        end

        # Remove code highlighting
        css('pre').each do |node|
          node.content = node.content
        end

        css('tt').each do |node|
          node.name = 'code'
        end

        doc
      end
    end
  end
end
