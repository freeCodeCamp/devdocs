module Docs
  class Javascript
    class EntriesFilter < Docs::EntriesFilter
      TYPES = %w(Array ArrayBuffer Atomics Boolean DataView Date Function
        Generator Intl JSON Map Math Number Object PluralRules Promise Reflect RegExp
        Set SharedArrayBuffer String Symbol TypedArray WeakMap WeakSet)
      INTL_OBJECTS = %w(Collator DateTimeFormat NumberFormat)

      def get_name
        if slug.start_with? 'Global_Objects/'
          name, method, *rest = *slug.sub('Global_Objects/', '').split('/')
          name.prepend 'Intl.' if INTL_OBJECTS.include?(name)

          if method
            unless method == method.upcase || method == 'NaN'
              method = method[0].downcase + method[1..-1] # e.g. Trim => trim
            end
            name << ".#{([method] + rest).join('.')}"
          end

          if name.exclude?('.prototype')
            path = name.split('.')
            if ((node = at_css('code')) && node.content =~ /(?:\s|\A)[a-z\_][a-zA-Z\_]+\.#{path.last}/) ||
               ((node = at_css('.standard-table')) && node.content =~ /\.prototype[\[\.]#{path.last}/)
              path[-2] = path[-2][0].downcase + path[-2][1..-1]
              name = path.join('.')
            end
          end

          name
        else
          name = super
          name.remove! 'Classes.'
          name.remove! 'Functions.'
          name.remove! 'Functions and function scope.'
          name.remove! 'Operators.'
          name.remove! 'Statements.'
          name.sub! 'Errors.', 'Errors: '
          name.sub! 'Strict mode.', 'Strict mode: '
          name
        end
      end

      def get_type
        if slug.start_with? 'Statements'
          'Statements'
        elsif slug.start_with? 'Operators'
          'Operators'
        elsif slug.start_with? 'Classes'
          'Classes'
        elsif slug.start_with? 'Errors'
          'Errors'
        elsif slug.start_with?('Functions') || slug.include?('GeneratorFunction') || slug.include?('AsyncFunction')
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
    end
  end
end
