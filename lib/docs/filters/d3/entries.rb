module Docs
  class D3
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        name
      end

      def additional_entries
        css('h6[id]').inject [] do |entries, node|
          name = node.content
          name.remove! %r{\(.*\z}
          entries << [name, node['id']] unless name == entries.last.try(:first)
          entries
        end
      end
    end
  end
end
