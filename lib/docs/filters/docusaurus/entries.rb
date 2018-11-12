module Docs
  class Docusaurus
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content
        name
      end

      def get_type
        link = doc.document.at_css('.navListItemActive')
        link && link.ancestors('.navGroup').first.at_css('h3').content
      end
    end
  end
end
