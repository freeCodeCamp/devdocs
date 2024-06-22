module Docs
  class Pandas
    class CleanHtmlOldFilter < Filter
      def call
        @doc = at_css('.body')

        if root_page?
          css('a[href$=".zip"]', 'a[href$=".pdf"]', '.toctree-wrapper').remove
          at_css('h1').content = 'pandas'
        end

        css('h2 > a.reference', 'h3 > a.reference').each do |node|
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
