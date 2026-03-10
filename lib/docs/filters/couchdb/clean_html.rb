module Docs
  class Couchdb
    class CleanHtmlFilter < Filter
      def call
        css('.section-number').remove
        css('.headerlink').remove

        css('.sig-name').each do |node|
          node.name = 'code'
        end

        css('pre').each do |node|
          node.content = node.content.strip

          classes = node.parent.parent.classes
          if classes.include? 'highlight-bash'
            node['data-language'] = 'bash'
          else
            node['data-language'] = 'javascript'
          end

          node.parent.parent.replace(node)
        end

        doc
      end
    end
  end
end
