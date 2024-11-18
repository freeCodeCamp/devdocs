module Docs
  class Wordpress
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        if subpath.starts_with?('classes') and subpath.count('/') == 3
          'Methods'
        elsif subpath.starts_with?('classes')
          'Classes'
        elsif subpath.starts_with?('hooks')
          'Hooks'
        elsif subpath.starts_with?('functions')
          'Functions'
        end
      end
    end
  end
end
