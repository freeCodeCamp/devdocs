module Docs
  class Zsh
    class CleanHtmlFilter < Filter
      def call
        css('table.header', 'table.menu', 'hr').remove

        # Remove indices from headers.
        css('h1', 'h2', 'h3').each do |node|
          node.content = node.content.match(/^[\d\.]* (.*)$/)&.captures&.first
        end

        css('h2.section ~ a').each do |node|
          node.next_element['id'] = node['name']
        end

        doc
      end
    end
  end
end
