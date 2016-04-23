module Docs
  class Modernizr
    class CleanHtmlFilter < Filter
      def call
        css('pre').each do |node|
          class_name = node.at_css('code')['class']
          node['data-language'] = class_name[/lang-(\w+)/, 1] if class_name
          node.content = node.content.strip_heredoc
        end

        css('sub').each do |node|
          node.before(node.children).remove
        end

        css('td:nth-child(2)').each do |node|
          node.name = node.previous_element.name = 'th'
        end

        doc
      end
    end
  end
end
