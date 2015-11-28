module Docs
  class Docker
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          @doc = at_css('.tabs-content')
        else
          @doc = at_css('#content')
        end

        if not at_css('h1')
          at_css('h2').name = 'h1'
        end

        css('pre').each do |node|
          node.content = node.content
        end

        doc
      end
    end
  end
end
