module Docs
  class Typescript
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        return 'Typescript' if current_url == root_url
        return at_css('h2').content
      end

      def get_type
        name
      end

      def additional_entries
        entries = []

        css('h2').each do |node|
            entries << [node.content, node['id'], name]
        end

        entries
      end

    end
  end
end
