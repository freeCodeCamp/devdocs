module Docs
  class Elasticsearch 
    class CleanHtmlFilter < Filter

      def call
        root_page? ? root : other
        page
        doc
      end

      def root
        # Remove the option block for allowing to change the version
        css('#book_title').remove

        # Remove annoying hr
        css('.titlepage>hr').remove

      end

      def page
        css('.navheader, .navfooter').remove
        css('.breadcrumbs').remove


      end

      def other
        css('a.edit_me').remove

        @doc = at_css('.titlepage').parent

        # Downgrade all headers.
        headers = (2..6).map { |n| "h#{n}" }.join(',') 
        css(headers).each do |header|
          level = header.name.last.to_i

          header.name = "h#{level-1}"
        end



        # Move the h1 of the title to be underneath the document 
        at_css('.titlepage').replace at_css('.titlepage h1.title')

        # Remove the note icon
        css('.icon').each(&:remove)

        # Remove table stylings
        css('table').each do |table|
          table.delete "cellpadding"
          table.delete "border"
          table.delete "cellpadding"
        end
      end

    end
  end
end

