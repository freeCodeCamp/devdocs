module Docs

  class EntryIndex
    # Override to prevent sorting.
    def entries_as_json
      @entries.map(&:as_json)
    end
    # Override to prevent sorting.
    def types_as_json
      @types.values.map(&:as_json)
    end
  end

  class Sanctuary
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        entries = []
        type = ""
        css("h3, h4").each do |node|
          case node.name
          when "h3"
            type = node.text
          when "h4"
            name = id = node.attributes["id"].value
            entries << [name, id, type]
          end
        end
        return entries
      end
    end
  end

end
