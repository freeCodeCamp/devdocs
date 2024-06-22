module Docs
  class Angular
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content
        name.prepend "#{$1}. " if subpath =~ /\-pt(\d+)/
        name
      end

      def get_type
        if slug.start_with?('guide')
          'Guide'
        elsif slug.start_with?('tutorial')
          'Tutorial'
        elsif slug.start_with?('api/platform-browser-dynamic')
          'platform-browser-dynamic'
        elsif node = at_css('th:contains("npm Package")')
          node.next_element.content.remove('@angular/')
        elsif at_css('.api-type-label.module')
          name.split('/').first
        elsif slug.start_with?('api/')
          slug.split('/').second
        else
          'Miscellaneous'
        end
      end
    end
  end
end
