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
          'Manual'
        elsif path.include?('lib/data-types')
          'datatypes'
        elsif path.include?('lib/errors/validation')
          'errors/validation'
        elsif path.include?('lib/errors/database')
          'errors/database'
        elsif path.include?('lib/errors/connection')
          'errors/connection'
        elsif path.include?('lib/errors')
          'errors'
        elsif path.include?('lib/associations')
          'associations'
        elsif path.include?('master/variable')
          'variables'
        else
          'classes'
        end
      end
    end
  end
end
