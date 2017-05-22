module Docs
  class Statsmodels
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.body', '#notebook-container')

        if root_page?
          at_css('h1').content = 'Statsmodels'
          at_css('#basic-documentation').remove
          at_css('#table-of-contents').remove
          at_css('#indices-and-tables').remove
        end

        css('div.cell', 'div.inner_cell', 'div.text_cell_render', 'div.input_area').each do |node|
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
