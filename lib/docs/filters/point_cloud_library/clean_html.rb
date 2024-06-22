module Docs
  class PointCloudLibrary
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.contents')
        css('.dynheader.closed').remove
        css('.permalink').remove
        css('.memSeparator').remove

        # Change div.fragment to C++ code with syntax highlight
        css('div.fragment').each do |node|
          node.name = 'pre'
          node['data-language'] = 'cpp'
          node_content = ""
          node.css('div').each do |inner_node|
            node_content += inner_node.text + "\n"
          end
          node.content = node_content
        end
        doc
      end
    end
  end
end
