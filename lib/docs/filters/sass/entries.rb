module Docs
  class Sass
    class EntriesFilter < Docs::EntriesFilter
      TYPES = ['CSS Extensions', 'SassScript', '@-Rules and Directives',
        'Output Styles']

      SKIP_NAMES = ['Interactive Shell', 'Data Types', 'Operations',
        'Division and /', 'Keyword Arguments']

      REPLACE_NAMES = {
        '%foo'               => '%placeholder selector',
        '&'                  => '& parent selector',
        '$'                  => '$ variables',
        '`'                  => '#{} interpolation',
        'The !optional Flag' => '!optional'
      }

      def get_name
        'Functions'
      end

      def get_type
        'Functions'
      end

      def additional_entries
        root_page? ? root_entries : function_entries
      end

      def root_entries
        entries = []
        type = ''

        css('*').each do |node|
          if node.name == 'h2'
            type = node.content.strip
            type.remove! %r{\s#.*}
            node['id'] = type.parameterize

            if type == 'Function Directives'
              entries << ['@function', node['id'], '@-Rules and Directives']
            end

            if type.include? 'Directives'
              type = '@-Rules and Directives'
            elsif type == 'Output Style'
              type = 'Output Styles'
            end

            next
          elsif node.name == 'h3' || node.name == 'h4'
            next unless TYPES.include?(type)

            name = node.content.strip
            name.remove! %r{\A.+?: }
            name.remove! %r{\s#.*}

            node['id'] = name.parameterize

            next if SKIP_NAMES.include?(name)

            name = REPLACE_NAMES[name] if REPLACE_NAMES[name]
            name.gsub!(/ [A-Z]/) { |str| str.downcase! }

            if type == '@-Rules and Directives'
              next unless name =~ /\A@[\w\-]+\z/ || name == '!optional'
            end

            entries << [name, node['id'], type]
          end
        end

        entries
      end

      def function_entries
        css('.method_details > .signature').inject [] do |entries, node|
          name = node.content.strip.remove(%r{\(.*})

          unless name == entries.last.try(:first)
            entries << [name, node['id'], 'Functions']
          end

          entries
        end
      end
    end
  end
end
