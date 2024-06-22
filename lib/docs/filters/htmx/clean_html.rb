module Docs
  class Htmx
    class CleanHtmlFilter < Filter
      def call
        css('.zola-anchor').remove
        doc.prepend_child("<h1>htmx</h1>") if root_page?
        css('div:contains("NEWS:")').remove
        css('h2:contains("sponsors"), #sponsor-table').remove
        doc
      end
    end
  end
end
