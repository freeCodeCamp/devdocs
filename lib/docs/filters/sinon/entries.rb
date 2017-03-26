module Docs
  class Sinon
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content.strip
      end

      def get_type
        name
      end

      def additional_entries
        css('h4 > code').each_with_object [] do |node, entries|
          name = node.content.strip
          name.sub! %r{\s*\(.*\);?}, '()'
          name.sub! %r{\A(\w+\.\w+)\s+\=.*}, '\1'
          name.remove! %r{\A.+?\=\s+}
          name.remove! %r{\A\w+?\s}
          name.remove! %r{;\z}

          next if entries.any? { |entry| entry[0].casecmp(name) == 0 }

          entries << [name, node.parent['id']]
        end
      end
    end
  end
end
