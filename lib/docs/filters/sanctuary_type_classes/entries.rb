module Docs
  class SanctuaryTypeClasses
    class EntriesFilter < Docs::EntriesFilter
      # The entire reference is one big page, so get_name and get_type are not necessary
      def additional_entries
        entries = []
        type = ""

        css("h2, h4").each do |node|
          case node.name
          when "h2"
            type = node.text
            if node.attributes["id"].value == "type-class-hierarchy"
              name = node.text
              id = node.attributes["id"].value
              entries << [name, id, type]
            end
          when "h4"
            name = node.text.split(' :: ')[0]
            id = name
            entries << [name, id, type]
          end
        end

        entries
      end
    end
  end
end
