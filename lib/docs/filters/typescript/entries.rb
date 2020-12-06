module Docs
  class Typescript
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        return at_css('h2').content
      end

      def get_type
        name
      end

      def additional_entries
        css('h2').each_with_object [] do |node,entries|
          entries << [node.content, node['id'], name]
        end
      end

    end
  end
end
