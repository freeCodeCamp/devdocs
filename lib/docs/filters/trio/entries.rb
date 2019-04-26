module Docs
  class Trio
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').text[0...-1]
      end

      def get_type
        at_css('h1').text[0...-1]
      end

      def additional_entries
        css('.descname').each_with_object [] do |node, entries|
          name = node.previous.text + node.text
          id = node.parent['id']
          entries << [name, id]
        end
      end
    end
  end
end
