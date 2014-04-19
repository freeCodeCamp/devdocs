module Docs
  class Postgresql
    class EntriesFilter < Docs::EntriesFilter
      REPLACE_NAMES = {
        'Sorting Rows'                    => 'ORDER BY',
        'Select Lists'                    => 'SELECT Lists',
        'Data Type Formatting Functions'  => 'Formatting Functions',
        'Enum Support Functions'          => 'Enum Functions',
        'Row and Array Comparisons'       => 'Array Comparisons',
        'Sequence Manipulation Functions' => 'Sequence Functions',
        'System Administration Functions' => 'Administration Functions',
        'System Information Functions'    => 'Information Functions' }

      def get_name
        name = at_css('h1').content
        clean_heading_name(name)

        if %w(Overview Introduction).include?(name)
          result[:pg_chapter_name]
        else
          name.remove! ' (Common Table Expressions)'
          REPLACE_NAMES[name] || name
        end
      end

      def clean_heading_name(name)
        name.remove! %r{\A[\d\.\s]+}
        name.remove! 'Using '
        name.remove! %r{\AThe }
        name
      end

      def get_type
        return if initial_page?

        if result[:pg_up_path] == 'sql-commands.html'
          'Commands'
        elsif result[:pg_up_path].start_with? 'reference-'
          'Applications'
        elsif type = result[:pg_chapter_name]
          if type.start_with?('Func') && (match = name.match(/\A(?!Form|Seq|Set|Enum)(.+) Func/))
            "Functions: #{match[1]}"
          else
            type.remove 'SQL '
          end
        end
      end

      def additional_entries
        return [] if skip_additional_entries?
        return get_config_entries if config_page?
        return get_heading_entries('h3[id]') if slug == 'functions-xml'

        if type == 'Data Types'
          return get_custom_entries case slug
            when 'rangetypes'          then 'li > p > .TYPE:first-child'
            when 'datatype-textsearch' then '.SECT2 > .TYPE'
            else '.CALSTABLE td:first-child > .TYPE' end
        end

        entries = get_heading_entries('h2[id]')

        if slug == 'queries-union'
          entries.concat get_custom_entries('p > .LITERAL:first-child')
        elsif slug == 'queries-table-expressions'
          entries.concat get_heading_entries('h3[id]')
          entries.concat get_custom_entries('dt > .LITERAL:first-child')
        elsif slug == 'functions-logical'
          entries.concat get_custom_entries('> table td:first-child > code')
        elsif slug == 'functions-formatting'
          entries.concat get_custom_entries('#FUNCTIONS-FORMATTING-TABLE td:first-child > code')
        elsif slug == 'functions-admin'
          entries.concat get_custom_entries('.TABLE td:first-child > code')
        elsif slug == 'functions-string'
          entries.concat get_custom_entries('> div[id^="FUNC"] td:first-child > code')
        elsif type && type.start_with?('Functions')
          entries.concat get_custom_entries('> .TABLE td:first-child > code:first-child')
          entries.concat get_comparison_entries if slug == 'functions-comparison'
        end

        entries
      end

      def get_config_entries
        css('.VARIABLELIST dt[id]').map do |node|
          name = node.at_css('.VARNAME').content
          ["Config: #{name}", node['id']]
        end
      end

      def get_heading_entries(selector)
        css(selector).inject [] do |entries, node|
          name = node.content
          clean_heading_name(name)

          unless skip_heading?(name)
            entries << ["#{additional_entry_prefix}: #{name}", node['id']]
          end

          entries
        end
      end

      def get_custom_entries(selector)
        css(selector).inject [] do |entries, node|
          name = node.content
          name.remove! %r{\(.*?\)}m
          name.remove! %r{\[.*?\]}m
          name.squeeze! ' '
          name.remove! %r{\([^\)]*\z} # bug fix: json_populate_record
          name = '||' if name.include? ' || '
          id = name.gsub(/[^a-z0-9\-_]/) { |char| char.ord }
          id = id.parameterize
          name.prepend "#{additional_entry_prefix}: "

          unless entries.any? { |entry| entry[0] == name }
            node['id'] = id
            entries << [name, id]
          end

          entries
        end
      end

      def get_comparison_entries
        %w(IS NULL BETWEEN DISTINCT\ FROM).map do |name|
          ["#{self.name}: #{name}"]
        end
      end

      def additional_entry_prefix
        type.dup.remove!('Functions: ') || self.name
      end

      def skip_additional_entries?
        slug == 'config-setting' || %w(Concurrency\ Control Localization).include?(type)
      end

      def skip_heading?(name)
        %w(Usage\ Patterns Portability Caveats Overview).include?(name) ||
        (type.start_with?('Functions') && slug != 'functions-xml' && name.split.first.upcase!)
      end

      def include_default_entry?
        !(initial_page? || at_css('.TOC') || config_page?)
      end

      def config_page?
        slug.start_with? 'runtime-config'
      end
    end
  end
end
