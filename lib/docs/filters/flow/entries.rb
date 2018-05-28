module Docs
  class Flow
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        return 'React' if slug.start_with?('react')
        type = at_css('.guide-nav .nav-item').content.strip
        type.remove! %r{ \(.*}
        type
      end
    end
  end
end
