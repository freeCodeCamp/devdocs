module Docs
  class Bluebird
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('.post-title')
        if name.nil?
          name = at_css('h2')
        end
        name.text
      end
    end
  end
end
