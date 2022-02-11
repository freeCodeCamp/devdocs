module Docs
  class Jasmine
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.docs') unless root_page?

        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = 'javascript'
        end

        doc
      end
    end
  end
end
