module Docs
  class Http
    class CleanHtmlFilter < Filter

      def call
        css('.column-container', '.column-half').each do |node|
          node.before(node.children).remove
        end

        css('p > code + strong').each do |node|
          code = node.previous_element
          if code.content =~ /\A[\s\d]+\z/
            code.content = "#{code.content.strip} #{node.content.strip}"
            node.remove
          end
        end

        css('strong > code').each do |node|
          node.parent.before(node.parent.children).remove
        end

        doc
      end

    end
  end
end
