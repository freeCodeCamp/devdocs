module Docs
  class Sequelize
    class EntriesFilter < Docs::EntriesFilter
      # Use the main title as the page name
      def get_name
        at_css('h1').text
      end

      # Assign the pages to main categories
      def get_type
        if base_url.path.include?('/docs/')
          'Manual'
        elsif path.include?('src/data-types')
          'datatypes'
        elsif path.include?('src/errors/validation')
          'errors/validation'
        elsif path.include?('src/errors/database')
          'errors/database'
        elsif path.include?('src/errors/connection')
          'errors/connection'
        elsif path.include?('src/errors')
          'errors'
        elsif path.include?('src/associations')
          'associations'
        elsif path.include?('master/variable')
          'variables'
        else
          'classes'
        end
      end

      def include_default_entry?
        at_css('.card > h2:contains("📄️")').nil?
      end

    end
  end
end
