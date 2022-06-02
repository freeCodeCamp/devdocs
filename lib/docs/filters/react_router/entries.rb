module Docs
  class ReactRouter
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        entries = []
        css('h2[id], h3[id]').each do |node|
          entries << [node.content, node['id'], 'API Reference']
        end
        entries
      end
    end
  end
end
