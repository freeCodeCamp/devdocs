module Docs
  class Sequel
    class EntriesFilter < Docs::Rdoc::EntriesFilter
      def get_name
        at_css('h1').content.split(' ').last.split('::')[1]
      end

      def get_type
        at_css('h1').content.split(' ').last.sub("Sequel::","")
      end

      def additional_entries
        return [] if initial_page?

        css('.signature').each_with_object [] do |node, entries| # Doesn't work, problems with css class
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
