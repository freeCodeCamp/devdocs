module Docs
  class Haskell
    class CleanHtmlFilter < Filter
      def call

        # remove unwanted elements
        css('#footer', '#package-header', '#module-header', '#synopsis', '.link', '#table-of-contents', '.empty', '.package').remove

        # turn captions into real headers
        css('.caption').each do |node|
          node.name = 'h2'
        end

        css('table .caption').each do |node|
          node.name = 'h3'
        end

        # # turn source listing in to pre
        css('.src').each do |node|
          node.name = 'pre'
        end


        if at_css('h1') && at_css('h1').content == 'Haskell Hierarchical Libraries'
          css('h1').remove
        end

        doc
      end
    end
  end
end
