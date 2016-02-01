module Docs
  class Influxdb
    class EntriesFilter < Docs::EntriesFilter
      
      def get_name
        at_css('#page-title h1').content
      end

      def get_type
        # This is kinda hacky, we are fetching the current type from
        # the url, we are asumming that the url pattern is
        # category/page or category
        path = current_url.relative_path_from(base_url)
        path.split('/').first.titleize
      end

    end
  end
end
