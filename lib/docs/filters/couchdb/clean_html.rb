module Docs
  class Couchdb
    class CleanHtmlFilter < Filter
      def call
        css('h1').each do |node|
          node.content = node.content.gsub(/\d*\. |\P{ASCII}/, '').split('.').last
        end

        css('h2', 'h3').each do |node|
          node.content = node.content.gsub(/\P{ASCII}/, '').split('.').last
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
