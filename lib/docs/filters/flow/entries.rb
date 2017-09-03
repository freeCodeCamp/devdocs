module Docs
  class Flow
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        type = at_css('.guide-nav .nav-item').content.strip
        type.remove! %r{ \(.*}
        type
      end
    end
  end
end
