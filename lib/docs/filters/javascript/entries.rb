module Docs
  class Javascript
    class EntriesFilter < Docs::EntriesFilter
      TYPES = %w(Array Boolean Date Function JSON Math Number Object RegExp String)

      ADDITIONAL_ENTRIES = {
        'operators/arithmetic_operators' => [
          %w(++ .2B.2B_.28Increment.29),
          %w(-- --_.28Decrement.29) ],
        'operators/bitwise_operators' => [
          %w(& .26_(Bitwise_AND)),
          %w(| .7C_(Bitwise_OR)),
          %w(^ .5E_(Bitwise_XOR)),
          %w(~ .7E_(Bitwise_NOT)),
          %w(<< <<_(Left_shift)),
          %w(>> >>_(Sign-propagating_right_shift)),
          %w(>>> >>>_(Zero-fill_right_shift)) ]}

      def get_name
        if slug.start_with? 'Global_Objects/'
          name, method = *slug.sub('Global_Objects/', '').split('/')

          if method
            unless method == method.upcase || method == 'NaN'
              method = method[0].downcase + method[1..-1] # e.g. Constructor => constructor
            end
            name << ".#{method}"
          end

          name
        else
          name = super
          name.sub! 'Functions and function scope.', ''
          name.sub! 'Operators.', ''
          name.sub! 'Statements.', ''
          name
        end
      end

      def get_type
        if slug.start_with? 'Statements'
          'Statements'
        elsif slug.start_with? 'Operators'
          'Operators'
        elsif slug.start_with? 'Functions_and_function_scope'
          'Function'
        elsif slug.start_with? 'Global_Objects'
          object, method = *slug.sub('Global_Objects/', '').split('/')
          if object.end_with? 'Error'
            'Errors'
          elsif method || TYPES.include?(object)
            object
          else
            'Global Objects'
          end
        end
      end

      def additional_entries
        ADDITIONAL_ENTRIES[slug] || []
      end
    end
  end
end
