module Docs
  class Sqlite
    class EntriesFilter < Docs::EntriesFilter
      ADDITIONAL_ENTRIES = {}

      def get_name
        name = context[:html_title]
        name.remove! 'SQLite Query Language: '
        name.remove! %r{\.\z}
        name = at_css('#document_title').content if name == 'No Title'
        name
      end

      TYPE_BY_SUBPATH_STARTS_WITH = {
        'c3ref' => 'C Interface',
        'capi' => 'C Interface',
        'session' => 'C Interface: Session Module',
        'optoverview' => 'Query Planner',
        'queryplanner' => 'Query Planner',
        'syntax' => 'Syntax Diagrams',
        'lang' => 'Language',
        'pragma' => 'PRAGMA Statements',
        'cli' => 'CLI',
        'json' => 'JSON',
        'fileformat' => 'Database File Format',
        'tcl' => 'Tcl Interface',
        'malloc' => 'Dynamic Memory Allocation',
        'vtab' => 'Virtual Table Mechanism',
        'datatype' => 'Datatypes',
        'locking' => 'Locking and Concurrency',
        'foreignkey' => 'Foreign Key Constraints',
        'wal' => 'Write-Ahead Logging',
        'fts' => 'Full-Text Search',
        'rtree' => 'R*Tree Module',
        'rbu' => 'RBU Extension',
        'limits' => 'Limits',
        'howtocorrupt' => 'How To Corrupt'
      }

      def get_type
        TYPE_BY_SUBPATH_STARTS_WITH.each_pair do |key, value|
          return value if subpath.start_with?(key)
        end

        if slug.in?(%w(cintro carray c_interface))
          'C Interface'
        elsif context[:html_title].start_with?('SQLite Query Language')
          'Query Language'
        else
          'Miscellaneous'
        end
      end

      IGNORE_ADDITIONAL_ENTRIES_SLUGS = %w(testing uri getthecode whentouse compile)

      def additional_entries
        if subpath == 'keyword_index.html'
          css('li a[href*="#"]').each do |node|
            slug, id = node['href'].split('#')
            name = node.content.strip
            next if name.start_with?('-') || IGNORE_ADDITIONAL_ENTRIES_SLUGS.include?(slug)
            name.remove! %r{\Athe }
            name.remove! %r{ SQL function\z}
            name = 'ORDER BY' if name == 'order by'
            name.sub!(/\A([a-z])([a-z]+) /) { "#{$1.upcase}#{$2} " }
            ADDITIONAL_ENTRIES[slug] ||= []
            ADDITIONAL_ENTRIES[slug] << [name, id]
          end
        end

        ADDITIONAL_ENTRIES[slug] || []
      end

      def include_default_entry?
        subpath != 'keyword_index.html' && subpath != 'sitemap.html'
      end
    end
  end
end
