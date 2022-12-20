module Docs
  class Wagtail
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        # removing the pilcrow sign and returning the heading
        at_css('h1').content.strip.remove("\u{00b6}")
      end

      def get_type
        object, method = *slug.split('/')
        method ? object : 'Miscellaneous'
      end
    end
  end
end
