module Docs
  class Cmake
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          css('#release-notes', '#index-and-search').remove

          css('h1').each do |node|
            node.name = 'h2'
          end
        end

        css('section').each do |node|
          node.children.each do |subnode|
            node.previous = subnode
          end
        end

        doc
      end
    end
  end
end
