module Docs
  class Docusaurus
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content
        name
      end

      def get_type
        doc.document.at_css('.navListItemActive').ancestors('.navGroup').first.at_css('h3').content
      end
    end
  end
end
