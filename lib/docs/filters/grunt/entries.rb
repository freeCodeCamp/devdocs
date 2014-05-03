module Docs
  class Grunt
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        if name.starts_with?('grunt') || name == 'Inside Tasks'
          name
        else
          'Miscellaneous'
        end
      end

      def additional_entries
        return [] unless subpath.starts_with?('api')

        css('h3').each_with_object [] do |node, entries|
          name = node.content
          name.remove! %r{\s.+\z}

          next if name == self.name

          entries << [name, node['id']]
        end
      end

      def include_default_entry?
        name != 'Inside Tasks'
      end
    end
  end
end
