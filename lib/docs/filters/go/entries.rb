module Docs
  class Go
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content
        name.sub! 'Package ', ''
        name
      end

      def get_type
        subpath[/\A[^\/]+/]
      end

      def additional_entries
        css('#manual-nav a').each_with_object [] do |node, entries|
          case node.content
          when /type\ (\w+)/
            name = $1
          when /func\ (?:\(.+\)\ )?(\w+)\(/
            name = "#{$1}()"
            name.prepend "#{$1}." if node['href'] =~ /#(\w+)\.#{$1}/
          end

          entries << ["#{name} (#{self.name})", node['href'][1..-1]] if name
        end
      end

      def include_default_entry?
        !at_css('h1 + table.dir')
      end
    end
  end
end
