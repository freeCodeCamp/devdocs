module Docs
  class Elasticsearch
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        css('.breadcrumbs span').last.content.strip
      end

      def get_type
        # get the second breadcrumb for our type,
        # the first is link to the main page (contents page)
        at_css('.breadcrumbs span:nth-child(2)').content.strip
      end

    end
  end

end
