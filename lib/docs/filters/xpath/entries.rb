module Docs
  class Xpath
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = super
        name.remove!('Axes.')
        name << '()' if name.gsub!('Functions.', '')
        name
      end

      def get_type
        if slug.start_with?('Axes')
          'Axes'
        elsif slug.start_with?('Functions')
          'Functions'
        else
          'Miscellaneous'
        end
      end
    end
  end
end
