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

      PREPEND_TYPES = [
        'Type Conversion',
        'Full Text Search',
        'Performance Tips',
        'Server Configuration',
        'Monitoring' ]

      REPLACE_TYPES = {
        'Routine Database Maintenance Tasks' => 'Maintenance',
        'High Availability, Load Balancing, and Replication' => 'High Availability',
        'Monitoring Database Activity' => 'Monitoring',
        'Monitoring Disk Usage' => 'Monitoring',
        'Reliability and the Write-Ahead Log' => 'Write-Ahead Log' }

      def base_name
        @base_name ||= clean_heading_name(at_css('h1').content)
      end

      def get_name
        if %w(Overview Introduction).include?(base_name)
          result[:pg_chapter_name]
        elsif PREPEND_TYPES.include?(type)
          "#{type}: #{base_name}"
        else
          REPLACE_NAMES[base_name] || base_name
        end
      end

      def get_type
        return if initial_page?

        if result[:pg_up_path] == 'sql-commands.html'
          'Commands'
        elsif result[:pg_up_path].start_with?('reference-')
          'Applications'
        elsif type = result[:pg_chapter_name]
          if type.start_with?('Func') && (match = base_name.match(/\A(?!Form|Seq|Set|Enum)(.+) Func/))
            "Functions: #{match[1]}"
          else
            type.remove! 'SQL '
            REPLACE_TYPES[type] || type
          end
        end
      end

      def additional_entries
        return [] if skip_additional_entries?
        return config_additional_entries if type && type.include?('Configuration')
        return data_types_additional_entries if type == 'Data Types'
        return get_heading_entries('h3[id]') if slug == 'functions-xml'

        entries = get_heading_entries('h2[id]')

        case slug
        when 'queries-union'
          entries.concat get_custom_entries('p > .LITERAL:first-child')
        when 'queries-table-expressions'
          entries.concat get_heading_entries('h3[id]')
          entries.concat get_custom_entries('dt > .LITERAL:first-child')
        when 'functions-logical'
          entries.concat get_custom_entries('> table td:first-child > code')
        when 'functions-formatting'
          entries.concat get_custom_entries('#FUNCTIONS-FORMATTING-TABLE td:first-child > code')
        when 'functions-admin'
          entries.concat get_custom_entries('.TABLE td:first-child > code')
        when 'functions-string'
          entries.concat get_custom_entries('> div[id^="FUNC"] td:first-child > code')
        else
          if type && type.start_with?('Functions')
            entries.concat get_custom_entries('> .TABLE td:first-child > code:first-child')
            entries.concat %w(IS NULL BETWEEN DISTINCT\ FROM).map { |name| ["#{self.name}: #{name}"] } if slug == 'functions-comparison'
          end
        end

        entries
      end

      def config_additional_entries
        css('.VARIABLELIST dt[id]').map do |node|
          name = node.at_css('.VARNAME').content
          ["Config: #{name}", node['id']]
        end
      end

      def data_types_additional_entries
        selector = case slug
        when 'rangetypes'
          'li > p > .TYPE:first-child'
        when 'datatype-textsearch'
          '.SECT2 > .TYPE'
        else
          '.CALSTABLE td:first-child > .TYPE'
        end
        get_custom_entries(selector)
      end

      def include_default_entry?
        !initial_page? && !at_css('.TOC')
      end

      SKIP_ENTRIES_SLUGS = [
        'config-setting',
        'applevel-consistency' ]

      SKIP_ENTRIES_TYPES = [
        'Localization',
        'Type Conversion',
        'Full Text Search',
        'Performance Tips',
        'Client Authentication',
        'Managing Databases',
        'Maintenance',
        'Backup and Restore',
        'High Availability',
        'Monitoring' ]

      def skip_additional_entries?
        SKIP_ENTRIES_SLUGS.include?(slug) || SKIP_ENTRIES_TYPES.include?(type)
      end

      def clean_heading_name(name)
        name.remove! %r{\A[\d\.\s]+}
        name.remove! 'Using '
        name.remove! %r{\AThe }
        name.remove! ' (Common Table Expressions)'
        name
      end

      def get_heading_entries(selector)
        css(selector).each_with_object([]) do |node, entries|
          name = node.content
          clean_heading_name(name)
          entries << ["#{additional_entry_prefix}: #{name}", node['id']] unless skip_heading?(name)
        end
      end

      def get_custom_entries(selector)
        css(selector).each_with_object([]) do |node, entries|
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
        end
      end

      def additional_entry_prefix
        type.dup.gsub!('Functions: ', '') || self.name
      end

      def skip_heading?(name)
        %w(Usage\ Patterns Portability Caveats Overview).include?(name) ||
        (type.start_with?('Functions') && slug != 'functions-xml' && name.split.first.upcase!)
      end
    end
  end
end
