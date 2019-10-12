module Docs
  class Sequelize
    class EntriesFilter < Docs::EntriesFilter
      # Use the main title as the page name
      def get_name
        at_css('h1').text
      end

      # Assign the pages to main categories
      def get_type
        if path.start_with?('manual/')
          type = 'Manual'
        elsif path.start_with?('file/lib/')
          type = 'Source files'
        else
          # API Reference pages. The `path` for most of these starts with 'class/lib/',
          # but there's also 'variable/index' (pseudo-classes), and 'identifiers' (the main index)
          # so we use an unqualified `else` as a catch-all.
          type = 'Reference'
        end

        type
      end
    end
  end
end
