module Docs
  class Javascript
    class EntriesFilter < Docs::EntriesFilter
      TYPES = %w(Array ArrayBuffer Boolean DataView Date Function Intl JSON Map
        Math Number Object Promise RegExp Set String Symbol TypedArray WeakMap
        WeakSet)
      INTL_OBJECTS = %w(Collator DateTimeFormat NumberFormat)

      def get_name
        if slug.start_with? 'Global_Objects/'
          name, method = *slug.sub('Global_Objects/', '').split('/')
          name.prepend 'Intl.' if INTL_OBJECTS.include?(name)

          if method
            unless method == method.upcase || method == 'NaN'
              method = method[0].downcase + method[1..-1] # e.g. Trim => trim
            end
            name << ".#{method}"
          end

          name
        else
          name = super
          name.remove! 'Functions.'
          name.remove! 'Functions and function scope.'
          name.remove! 'Operators.'
          name.remove! 'Statements.'
          name
        end
      end

      def get_type
        if slug.start_with? 'Statements'
          'Statements'
        elsif slug.start_with? 'Operators'
          'Operators'
        elsif slug.start_with?('Functions_and_function_scope') || slug.start_with?('Functions') || slug.include?('GeneratorFunction')
          'Function'
        elsif slug.start_with? 'Global_Objects'
          object, method = *slug.remove('Global_Objects/').split('/')
          if object.end_with? 'Error'
            'Errors'
          elsif INTL_OBJECTS.include?(object)
            'Intl'
          elsif method || TYPES.include?(object)
            object
          else
            'Global Objects'
          end
        else
          'Miscellaneous'
        end
      end

      def include_default_entry?
        node = doc.at_css '.overheadIndicator'

        # Can't use :first-child because #doc is a DocumentFragment
        return true unless node && node.parent == doc && !node.previous_element

        !node.content.include?('not on a standards track') &&
        !node.content.include?('removed from the Web') &&
        !node.content.include?('could be removed at any time')
      end
    end
  end
end
