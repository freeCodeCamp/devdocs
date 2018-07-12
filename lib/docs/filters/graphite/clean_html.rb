module Docs
  class Graphite
    class CleanHtmlFilter < Filter
      def call
        # Remove the paragraph icon after all headers
        css('.headerlink').remove

        # Extract the text from function titles to get rid of the inconsistent styling
        css('dl.function > dt').each do |node|
          node['data-name'] = node.at_css('.descname').inner_html.to_s
          node.content = node.text
        end

        doc
      end
    end
  end
end
