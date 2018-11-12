module Docs
  class Docusaurus
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content
        name
      end

      def get_type
        doc.document
          .at_css('.toc .navListItemActive') # toc is for doc pages, toc-headings is for headings
          .parent # ul
          .parent # .navGroup
          .at_css('h3') # title
          .text
      end
    end
  end
end
