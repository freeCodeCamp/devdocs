module Docs
  class Immutablejs
    class EntriesFilter < Docs::EntriesFilter
      def name
        typeHeader = at_css('h1.typeHeader')
        return typeHeader.content if typeHeader
      end

      def type
        typeHeader = at_css('h1.typeHeader')
        return typeHeader.content if typeHeader

        # TODO: Is this ok? This the index page.. I don't think it should have it's own type..
        nil
      end


      def additional_entries
        if current_url.fragment.nil?
          return []
        end

        css('h3.memberLabel').map do |memberLabel|
          entry_name = "#{type}##{memberLabel.content}"
          [entry_name, memberLabel.content.chomp('()')]
        end
      end

    end
  end
end
