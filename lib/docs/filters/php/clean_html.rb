module Docs
  class Php
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
        doc.inner_html = ' '
      end

      def other
        css('.manualnavbar', 'hr').remove

        # Remove top-level <div>
        if doc.elements.length == 1
          @doc = doc.first_element_child
        end

        # Remove code highlighting
        br = /<br\s?\/?>/i
        css('.phpcode').each do |node|
          node.name = 'pre'
          node.inner_html = node.inner_html.gsub(br, "\n")
          node.content = node.content
        end
      end
    end
  end
end
