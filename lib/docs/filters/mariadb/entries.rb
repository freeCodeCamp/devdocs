module Docs
  class Mariadb
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('.container > h1').content.strip
      end

      def get_type
        link = at_css('#breadcrumbs > a:nth-child(6)')
        link.nil? ? at_css('#breadcrumbs > a:nth-child(5)').content : link.content
      end
    end
  end
end
