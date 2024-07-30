module Docs
  class Man
    class CleanHtmlFilter < Filter
      def call
        css('.page-top').remove
        css('.nav-bar').remove
        css('.nav-end').remove
        css('.sec-table').remove
        css('a[href="#top_of_page"]').remove
        css('.end-man-text').remove
        css('.start-footer').remove
        css('.footer').remove
        css('.end-footer').remove
        css('.statcounter').remove
        css('form[action="https://www.google.com/search"]').remove
        doc
      end
    end
  end
end
