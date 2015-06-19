module Docs
  class Opentsdb 
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        header = css(".section > h1").first
        return header.content.strip unless header.nil?
      end

      def get_type
        return nil if breadcrumbs.length < 2 

        # This is time for a little bit of cheating
        return breadcrumbs[1] if breadcrumbs.include? "HTTP API"

        breadcrumbs.last
      end

      def additional_entries
        []
      end


      def breadcrumbs
        nav_links = css(".related").first.css("li")
        breadcrumbs = nav_links.reject do |node|
          node['class'] == "right"
        end

        breadcrumbs.map { |node| node.at_css("a").content }
          .reject { |link| link.empty? }
      end
    end
  end
end
