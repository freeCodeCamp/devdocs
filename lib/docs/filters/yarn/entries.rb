module Docs
  class Yarn
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content

        name
      end

      def get_type
        type = at_css('.guide-nav a').content.strip
        type.sub! 'CLI Introduction', 'CLI Commands'
        type
      end
    end
  end
end
