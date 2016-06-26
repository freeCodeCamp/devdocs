module Docs
  class Matplotlib
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name.remove! "\u{00b6}"
        name
      end

      def get_type
        name = at_css('h1').content.strip
        name.remove! "\u{00b6}"
        name
      end

      def additional_entries
        entries = []
        ents = css('dt .descname')

        if ents
          ents.each do |node|
            name = node.content.sub(/\(.*\)/, '()')
            id = node.parent['id']
            entries << [name, id, get_name]
          end
        end
        entries
      end
    end
  end
end
