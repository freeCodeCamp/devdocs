module Docs
  class Fluture
    class EntriesFilter < Docs::EntriesFilter
      # The entire reference is one big page, so get_name and get_type are not necessary
      def additional_entries
        entries = []
        type = ""

        css("h3, h4").each do |node|
          case node.name
          when "h3"
            type = node.text
          when "h4"
            name = node.text
            id = node.text.downcase
            entries << [name, id, type]
          end
        end

        entries
      end
    end
  end
end
