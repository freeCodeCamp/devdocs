module Docs
  class Jasmine
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name.remove! %r{\A\w+:\s}
        name
      end

      def get_type
        at_css('h1').content.strip
      end

      def additional_entries
        css('h3[id]').each_with_object [] do |node, entries|
          name = node.content.strip
          next if name.start_with?('new ')
          static = name.sub! '(static) ', ''
          name.sub! %r{\(.*\)}, '()'
          name.remove! %r{\s.*}
          name.prepend "#{self.name}#{static ? '.' : '#'}" unless slug == 'global'
          entries << [name, node['id']]
        end
      end
    end
  end
end
