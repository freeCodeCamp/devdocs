module Docs
  class Leaflet
    class CleanHtmlFilter < Filter
      def call
        css('#toc', '.expander').remove

        # remove "This reference reflects Leaflet 1.2.0."
        css('h2 ~ p').each do |node|
          node.remove
          break
        end

        # syntax highlighting
        css('code.lang-js').each do |node|
          node.parent['data-language'] = 'javascript'
          node.parent.content = node.content
        end

        doc
      end
    end
  end
end
