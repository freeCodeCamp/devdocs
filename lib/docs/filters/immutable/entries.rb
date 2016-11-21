module Docs
  class Immutable
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        entries = []
        type = nil

        css('*').each do |node|
          if node.name == 'h1'
            name = node.content
            type = node.content.split('.').first
            entries << [name, node['id'], type]
          elsif node.name == 'h3'
            name = node.content
            entries << [name, node['id'], type]
          end
        end

        entries
      end
    end
  end
end
