module Docs
  class Twig
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        if slug.start_with?('filters')
          'Filters'
        elsif slug.start_with?('functions')
          'Functions'
        elsif slug.start_with?('tags')
          'Tags'
        elsif slug.start_with?('tests')
          'Tests'
        elsif slug.start_with?('extensions')
          'Extensions'
        else
          'Miscellaneous'
        end
      end
    end
  end
end
