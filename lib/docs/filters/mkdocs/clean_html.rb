module Docs
  class Mkdocs
    class CleanHtmlFilter < Docs::Filter
      def call
        css('.toclink').each do |node|
          node.parent.content = node.content
        end

        css('pre').each do |node|
          node.content = node.at_css('code').content
        end

        at_css('#main-content')
      end
    end
  end
end
