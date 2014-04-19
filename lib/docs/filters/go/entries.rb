module Docs
  class Go
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content
        name.remove! 'Package '
        name
      end

      def get_type
        subpath[/\A[^\/]+/]
      end

      def additional_entries
        css('#manual-nav a').each_with_object [] do |node, entries|
          case node.content
          when /type\ (\w+)/
            name = "#{$1} (#{self.name})"
          when /func\ (?:\(.+\)\ )?(\w+)\(/
            name = "#{$1}() (#{self.name})"
            name.prepend "#{$1}." if node['href'] =~ /#(\w+)\.#{$1}/
          when 'Constants'
            name = "#{self.name} constants"
          when 'Variables'
            name = "#{self.name} variables"
          end

          entries << [name, node['href'][1..-1]] if name
        end
      end

      def include_default_entry?
        !at_css('h1 + table.dir')
      end
    end
  end
end
