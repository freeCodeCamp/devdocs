module Docs
  class Wordpress
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        # Undo the smart quotes that developer.wordpress.org applies to the
        # default values in signatures (e.g. = ‘default’ and = ” for '')
        at_css('h1').content
          .gsub('= “”', '= ""')
          .gsub('= ”', "= ''")
          .gsub(/= ‘([^’]*)’/, "= '\\1'")
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
