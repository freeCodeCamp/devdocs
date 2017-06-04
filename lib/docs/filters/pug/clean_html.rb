module Docs
  class Pug
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.main')

        at_css('h1').content = 'Pug Documentation' if root_page?

        if slug == 'api/reference'
          at_css('.alert-info').remove
        end

        css('.header-anchor').remove

        css('.preview-wrapper').each do |node|
          node.css('pre').each do |n|
            node.before(n)
          end
          node.remove
        end

        css('pre').each do |node|
          node.content = node.content
        end

        doc
      end
    end
  end
end
