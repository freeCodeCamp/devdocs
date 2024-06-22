module Docs
  class Mariadb
    class EraseInvalidPagesFilter < Filter
      @@seen_urls = Hash.new

      def call
        # The MariaDB documentation uses urls like mariadb.com/kb/en/*
        # This means there is no way to detect if a page should be scraped based on it's url
        # We run this filter before the internal_urls filter scrapes all internal urls
        # If this page should not be scraped, we erase it's contents in here so that the internal urls are not picked up
        # The entries filter will make sure that no entry is saved for this page

        if at_css('a.crumb[href="https://mariadb.com/kb/en/documentation/"]').nil? and at_css('a.crumb[href="https://mariadb.com/kb/en/training-tutorials/"]').nil?
          doc.inner_html = ''
        elsif at_css('.question') and at_css('.answer')
          doc.inner_html = ''
        end

        current_page = at_css('a.crumb.node_link')
        unless current_page.nil?
          url = current_page['href']

          # Some links lead to the same page
          # Only parse the page one time
          if @@seen_urls.has_key?(url)
            doc.inner_html = ''
          end

          @@seen_urls[url] = true
        end

        doc
      end
    end
  end
end
