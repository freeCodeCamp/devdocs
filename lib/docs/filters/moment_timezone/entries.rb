module Docs
  class MomentTimezone
    class EntriesFilter < Docs::EntriesFilter

      def additional_entries
        entries = []
        type = nil

        css('[id]').each do |node|
          if node.name == 'h2'
            type = node.content
          end
          name = node.content.strip
          entries << [name, node['id'], type]
        end

        entries
      end
    end
  end
end
