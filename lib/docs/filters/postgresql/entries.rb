module Docs
  class Postgresql
    class EntriesFilter < Docs::EntriesFilter
      REPLACE_NAMES = {
        'Sorting Rows'                    => 'ORDER BY',
        'Select Lists'                    => 'SELECT Lists',
        'Comparison Functions and Operators' => 'Comparisons',
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
        'Reliability and the Write-Ahead Log' => 'Write-Ahead Log',
        'Overview of PostgreSQL Internals' => 'Internals',
        'System Catalogs' => 'Internals: Catalogs',
        'How the Planner Uses Statistics' => 'Internals',
        'Index Access Method Interface Definition' => 'Index Access Method',
        'Database Physical Storage' => 'Physical Storage' }

      INTERNAL_TYPES = [
        'Genetic Query Optimizer',
        'Index Access Method',
        'GiST Indexes',
        'SP-GiST Indexes',
        'GIN Indexes',
        'BRIN Indexes',
        'Physical Storage' ]

      def base_name
        @base_name ||= clean_heading_name(at_css('h1').content)
      end

      def heading_level
        @heading_level ||= at_css('h1').content.scan(/\d+(?=\.)/).last
      end

      def get_name
        if type.start_with?('Tutorial')
          "#{heading_level}. #{base_name}"
        elsif %w(Overview Introduction).include?(base_name)
          result[:pg_chapter_name]
        elsif PREPEND_TYPES.include?(type) || type.start_with?('Internals')
          "#{type.remove('Internals: ')}: #{base_name}"
        else
          REPLACE_NAMES[base_name] || base_name
        end
      end

      def get_type
        return if initial_page?

        if result[:pg_up_path] == 'sql-commands.html'
          'Commands'
        elsif result[:pg_up_path] == 'appendixes.html'
          'Appendixes'
        elsif result[:pg_up_path].start_with?('reference-')
          'Applications'
        elsif type = result[:pg_chapter_name]
          if type.start_with?('Func') && (match = base_name.match(/\A(?!Form|Seq|Set|Enum|Comp)(.+) Func/))
            "Functions: #{match[1]}"
          else
            type.remove! %r{\ASQL }
            type = REPLACE_TYPES[type] || type
            type.prepend 'Internals: ' if INTERNAL_TYPES.include?(type)
            type.prepend 'Tutorial: ' if slug.start_with?('tutorial')
            type
          end
        elsif type = result[:pg_appendix_name]
          type.prepend 'Appendix: '
          type
        end
      end

      def additional_entries
        return [] if skip_additional_entries?
        return config_additional_entries if type && type.include?('Configuration')
        return data_types_additional_entries if type == 'Data Types'
        return command_additional_entries if type == 'Commands'
        return get_heading_entries('h3[id], .sect3[id] > h3:first-child') if slug == 'functions-xml'

        entries = get_heading_entries('h2[id], .sect2[id] > h2:first-child')

        case slug
        when 'queries-union'
          entries.concat get_custom_entries('p > .literal:first-child')
        when 'queries-table-expressions'
          entries.concat get_heading_entries('h3[id], .sect3[id] > h3:first-child')
          entries.concat get_custom_entries('dt > .literal:first-child')
        when 'functions-logical'
          entries.concat get_custom_entries('> table td:first-child > code')
        when 'functions-formatting'
          entries.concat get_custom_entries('#FUNCTIONS-FORMATTING-TABLE td:first-child > code')
        when 'functions-admin'
          entries.concat get_custom_entries('.table td:first-child > code')
        when 'functions-string'
          entries.concat get_custom_entries('> div[id^="FUNC"] td:first-child > code')
          entries.concat get_custom_entries('> div[id^="FORMAT"] td:first-child > code')
        else
          if type && type.start_with?('Functions')
            entries.concat get_custom_entries('> .table td:first-child > code.literal:first-child')
            entries.concat get_custom_entries('> .table td:first-child > code.function:first-child')
            entries.concat get_custom_entries('> .table td:first-child > code:not(.literal):first-child + code.literal')
            entries.concat get_custom_entries('> .table td:first-child > p > code.literal:first-child')
            entries.concat get_custom_entries('> .table td:first-child > p > code.function:first-child')
            entries.concat get_custom_entries('> .table td:first-child > p > code:not(.literal):first-child + code.literal')
            if slug == 'functions-comparison' && !at_css('#FUNCTIONS-COMPARISON-PRED-TABLE') # before 9.6
              entries.concat %w(IS NULL BETWEEN DISTINCT\ FROM).map { |name| ["#{self.name}: #{name}"] }
            end
          end
        end

        entries
      end

      def config_additional_entries
        css('.variablelist dt[id]').map do |node|
          name = node.at_css('.varname').content
          ["Config: #{name}", node['id']]
        end
      end

      def data_types_additional_entries
        selector = case slug
        when 'rangetypes'
          'li > p > .type:first-child'
        when 'datatype-textsearch'
          '.title > .type, .sect2 > .type'
        else
          '.table-contents td:first-child > .type, .calstable td:first-child > .type'
        end
        get_custom_entries(selector)
      end

      def command_additional_entries
        css('.refsect2[id^="SQL"]').each_with_object([]) do |node, entries|
          next unless heading = node.at_css('h3')
          next unless heading.content.strip =~ /[A-Z_\-]+ Clause/
          name = heading.at_css('.literal').content
          name.prepend "#{self.name} ... "
          entries << [name, node['id']]
        end
      end

      def include_default_entry?
        !initial_page? && (!at_css('.toc') || at_css('.sect2, .variablelist, .refsect1')) && type
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
        return true unless type
        SKIP_ENTRIES_SLUGS.include?(slug) ||
        SKIP_ENTRIES_TYPES.include?(type) ||
        type.start_with?('Internals') ||
        type.start_with?('Tutorial') ||
        type.start_with?('Appendix')
      end

      def clean_heading_name(name)
        name.remove! 'Chapter '
        name.remove! %r{\A[\d\.\s]+}
        name.remove! 'Appendix '
        name.remove! %r{\A[A-Z]\.[\d\.\s]*}
        name.remove! 'Using '
        name.remove! %r{\AThe }
        name.remove! ' (Common Table Expressions)'
        name
      end

      def get_heading_entries(selector)
        css(selector).each_with_object([]) do |node, entries|
          name = node.content
          clean_heading_name(name)
          id = node['id'] || node.parent['id']
          raise "missing ids for selector #{selector}" unless id
          entries << ["#{additional_entry_prefix}: #{name}", id] unless skip_heading?(name)
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
          id = name.gsub(/[^a-zA-Z0-9\-_]/) { |char| char.ord }
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
