module Docs
  class TclTk
    class EntriesFilter < Docs::EntriesFilter
      TYPE_MAP = {
        'UserCmd' => 'Applications',
        'TclCmd' => 'Tcl',
        'TkCmd' => 'Tk',
        'ItclCmd' => '[incr Tcl]',
        'SqliteCmd' => 'TDBC',
        'TdbcCmd' => 'TDBC',
        'TdbcmysqlCmd' => 'TDBC',
        'TdbcodbcCmd' => 'TDBC',
        'TdbcpostgresCmd' => 'TDBC',
        'TdbcsqliteCmd' => 'TDBC',
        'ThreadCmd' => 'Thread'
      }

      def get_name
        if slug.end_with?('contents.htm')
          slug.split('/').first
        else
          slug.split('/').last.remove('.htm')
        end
      end

      def get_type
        TYPE_MAP.fetch(slug.split('/').first)
      end

      def additional_entries
        css('> dl.command > dt > a[name]:not([href])', '> dl.commands > dt > a[name]:not([href])').each_with_object [] do |node, entries|
          name = node.at_xpath("./b[not(text()='#{self.name}')]").try(:content)
          next unless name
          name.strip!
          name.remove! %r{\A:+}
          name.prepend "#{self.name}: " unless name =~ /#{self.name}[:\s]/ || name =~ /#{self.name.gsub('_', '::')}[:\s]/
          next if entries.any? { |entry| entry[0] == name }
          entries << [name, node['name']]
        end
      end
    end
  end
end
