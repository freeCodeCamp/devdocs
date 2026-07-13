module Docs
  class Tokio
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        namespace = at_css('.rustdoc-breadcrumbs').inner_text
        header = at_css('h1 > span').inner_text
        "#{namespace}::#{header}"
      end

      def get_type
        header = at_css('h1').inner_text

        if header.include?('Attribute Macro')
          'Attribute Macros'
        elsif header.include?('Macro')
          'Macros'
        elsif header.include?('Module')
          'Modules'
        elsif header.include?('Struct')
          'Structs'
        elsif header.include?('Function')
          'Functions'
        elsif header.include?('Enum')
          'Enums'
        elsif header.include?('Trait')
          'Traits'
        elsif header.include?('Type')
          'Types'
        else
          'Other'
        end
      end
    end
  end
end
