module Docs
  class Zig
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        entries = []
        type = nil
        subtype = nil

        css('h2, h3').each do |node|
          if node.name == 'h2' && node['id']
            type = node.content.gsub(/ §/, '')
            subtype = nil
            entries << [type, node['id'], type]
          elsif node.name == 'h3' && node['id']
            subtype = node.content.gsub(/ §/, '')
            name = "#{type}: #{subtype}"
            entries << [name, node['id'], type]
          end
        end

        entries
      end
    end
  end
end
