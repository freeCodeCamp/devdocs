module Docs
  class Javascript
    class EntriesFilter < Docs::EntriesFilter
      TYPES = %w(Array ArrayBuffer Atomics Boolean DataView Date Function
        Generator Intl JSON Map Math Number Object PluralRules Promise Reflect RegExp
        Set SharedArrayBuffer SIMD String Symbol TypedArray WeakMap WeakSet)
      INTL_OBJECTS = %w(Collator DateTimeFormat NumberFormat)

      def get_name
        if slug.start_with? 'Global_Objects/'
          name, method, *rest = *slug.sub('Global_Objects/', '').split('/')
          name.prepend 'Intl.' if INTL_OBJECTS.include?(name)
          name.prepend 'SIMD.' if html.include?("SIMD.#{name}")

          if method
            unless method == method.upcase || method == 'NaN'
              method = method[0].downcase + method[1..-1] # e.g. Trim => trim
            end
            name << ".#{([method] + rest).join('.')}"
          end

          if name.exclude?('.prototype')
            path = name.split('.')
            if ((node = at_css('.syntaxbox') || at_css('code')) && node.content =~ /(?:\s|\A)[a-z\_][a-zA-Z\_]+\.#{path.last}/) ||
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
          elsif name.start_with?('SIMD')
            'SIMD'
          elsif method || TYPES.include?(object)
            object
          else
            'Global Objects'
          end
        else
          'Miscellaneous'
        end
      end

      def additional_entries
        return [] unless root_page?
        entries = []

        %w(arithmetic assignment bitwise comparison logical).each do |s|
          css("a[href^='operators/#{s}_operators#']").each do |node|
            name = CGI::unescapeHTML(node.content.strip)
            name.remove! %r{[a-zA-Z]}
            name.strip!
            entries << [name, node['href'], 'Operators']
          end
        end

        entries.uniq
      end

      def include_default_entry?
        node = doc.at_css '.blockIndicator, .warning'

        # Can't use :first-child because #doc is a DocumentFragment
        return true unless node && node.parent == doc && !node.previous_element

        !node.content.include?('not on a standards track') &&
        !node.content.include?('removed from the Web') &&
        !node.content.include?('SpiderMonkey-specific feature, and will be removed') &&
        !node.content.include?('could be removed at any time')
      end
    end
  end
end
