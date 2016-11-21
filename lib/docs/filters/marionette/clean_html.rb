module Docs
  class Marionette
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
        at_css('p').remove
        at_css('h1').content = 'Backbone.Marionette'
      end

      def other
        css('#source + h2', '#improve', '#source', '.glyphicon').remove

        css('p > br').each do |node|
          node.replace(' ')
        end

        css('pre > code').each do |node|
          node.parent['data-language'] = node['class'][/lang-(\w+)/, 1] if node['class']
          node.before(node.children).remove
        end

        css('h2', 'h3').each do |node|
          if anchor = node.at_css('a.anchor[name]')
            id = anchor['name']
          else
            id = node.content.strip
            id.downcase!
            id.remove! %r{['"\/\.:]}
            id.gsub! %r{[\ _]}, '-'
          end
          node['id'] = id
        end
      end
    end
  end
end
