module Docs
  class Chef
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('div.body h1 a').remove
        at_css('div.body h1').content
      end
    end
  end
end
