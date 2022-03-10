module Docs
  class Eigen3
    class CleanHtmlFilter < Filter

      def call
        @doc = at_css('#doc-content')
        css('#MSearchSelectWindow').remove
        css('#MSearchResultsWindow').remove
        css('.directory .levels').remove
        css('.header .summary').remove
        css('.ttc').remove
        css('.top').remove
        css('.dynheader.closed').remove
        css('.permalink').remove

        css("div.fragment").each do |node|
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
