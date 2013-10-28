module Docs
  class Less
    class EntriesFilter < Docs::EntriesFilter
      SKIP_NAMES = ['Parametric Mixins', 'Mixins With Multiple Parameters',
        'Return Values', 'Unlocking Mixins', 'Media Queries as Variables']

      REPLACE_NAMES = {
        'The @arguments variable'                   => '@arguments',
        'Advanced arguments and the @rest variable' => '@rest',
        'The Keyword !important'                    => '!important',
        'Pattern-matching and Guard expressions'    => 'Pattern-matching',
        'Advanced Usage of &'                       => '&',
        'Importing'                                 => '@import',
        'JavaScript evaluation'                     => 'JavaScript',
        '% format'                                  => '%'
      }

      def include_default_entry?
        false
      end

      def additional_entries
        entries = []
        type = ''

        css('> [id]').each do |node|
          if node.name == 'h2'
            type = node.content.strip
            type.sub! 'The Language', 'Language'
            type.sub! 'functions', 'Functions'
            next
          end

          # Skip function categories (e.g. "Color definition")
          next if node.name == 'h3' && type != 'Language'

          name = node.content.strip

          next if SKIP_NAMES.include?(name)

          name = REPLACE_NAMES[name] if REPLACE_NAMES[name]
          name.gsub!(/ [A-Z]/) { |str| str.downcase! }

          entries << ['~', node['id'], type] if name == 'e'
          entries << [name, node['id'], type]
        end

        entries
      end
    end
  end
end
