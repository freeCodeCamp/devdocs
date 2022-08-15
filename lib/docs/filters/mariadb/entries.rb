module Docs
  class Mariadb
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        return 'Name' if doc.inner_html == ''

        at_css('#content > h1').content.strip
      end

      def get_type
        return 'Type' if doc.inner_html == ''
        return 'Tutorials' if at_css('a.crumb[href]:contains("Training & Tutorials")')

        link = at_css('#breadcrumbs > a:nth-child(4)')
        link.nil? ? at_css('#breadcrumbs > a:nth-child(3)').content : link.content
      end

      def entries
        # Don't add an entry for this page if the EraseInvalidPagesFilter detected this page shouldn't be scraped
        return [] if doc.inner_html == ''
        super
      end
    end
  end
end
