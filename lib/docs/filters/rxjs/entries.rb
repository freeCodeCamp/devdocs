module Docs
  class Rxjs
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content
        name.prepend "#{$1}. " if subpath =~ /\-pt(\d+)/
        name
      end

      def get_type
        if slug.start_with?('guide')
          'Guide'
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
