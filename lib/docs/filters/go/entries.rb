module Docs
  class Go
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        code = at_css('code')
        if code && name = code.content[/import "([\w\/]+)"/, 1]
          name
        else
          name = at_css('h1').content
          name.remove! 'Package '
          name
        end
      end

      def get_type
        package = subpath[/\A[^\/]+/]
        if package.in?(%w(math net))
          name.split('/')[0..1].join('/')
        else
          package
        end
      end

      def additional_entries
        return [] if root_page?
        package = self.name.split('/').last
        css('#manual-nav a').each_with_object [] do |node, entries|
          case node.content
          when /type\ (\w+)/
            name = "#{package}.#{$1}"
          when /func\ (?:\(.+\)\ )?(\w+)\(/
            name = "#{$1}()"
            name.prepend "#{$1}." if node['href'] =~ /#(\w+)\.#{$1}/
            name.prepend "#{package}."
          when 'Constants'
            name = "#{self.name} constants"
          when 'Variables'
            name = "#{self.name} variables"
          end

          entries << [name, node['href'][1..-1]] if name
        end
      end

      def include_default_entry?
        !at_css('h1 + .pkg-dir')
      end
    end
  end
end
