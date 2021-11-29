module Docs
  class I3
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        entries = []
        type = nil
        css('h2[id], h3[id]').each do |node|
          if node.name == 'h2' && node['id']
            type = node.content
          end
          entries << [node.content, node['id'], type]
        end
        entries
      end
    end
  end
end
