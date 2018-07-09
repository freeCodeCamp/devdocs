module Docs
  class Leaflet
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        entries = []
        type = nil
        subtype = nil

        css('*').each do |node|
          if node.name == 'h2' && node['id']
            type = node.content
            subtype = nil
            entries << [type, node['id'], type]
          elsif node.name == 'h3'
            subtype = node.content
          elsif node.name == 'tr' && node['id']
            value = node.css('td > code > b').first.content
            if subtype && subtype.end_with?(' options')
              name = "#{subtype}: #{value}"
            elsif subtype
              name = "#{type} #{subtype.downcase}: #{value}"
            else
              name = "#{type}: #{value}"
            end
            entries << [name, node['id'], type]
          end
        end

        entries
      end
    end
  end
end
