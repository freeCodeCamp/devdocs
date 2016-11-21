module Docs
  class Yarn
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content

        unless type == 'CLI'
          name.prepend "#{css('.guide-nav a').to_a.index(at_css('.guide-nav a.active')) + 1}. "
        end

        name
      end

      def get_type
        type = at_css('.guide-nav a').content.strip
        type.remove! ' Introduction'
        type
      end
    end
  end
end
