module Docs
  class Padrino
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content.split(' ').last
      end

      def get_type
        name.split('::')[0..1].join('::')
      end

      def additional_entries
        return [] if initial_page?

        css('.signature').each_with_object [] do |node, entries|
          next if node.ancestors('.overload').present?
          name = node.content.strip
          name.remove! %r{[\s\(].*}
          name.prepend(self.name)
          entries << [name, node['id']]
        end
      end

      def include_default_entry?
        !initial_page?
      end
    end
  end
end
