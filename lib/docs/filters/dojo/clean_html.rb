module Docs
  class Dojo
    class CleanHtmlFilter < Filter
      def call
        css('script').remove

        css('.version').remove

        #Remove links which are broken on the methods
        doc.css(".functionIcon a").each do |a|
            a.replace a.content
        end

        doc
      end
    end
  end
end
