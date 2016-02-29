module Docs
  class Tensorflow
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        at_css('h1').content
      end

      def include_default_entry?
        false
      end

      def additional_entries
        entries = []

        # Just get everything that is a code tag inside a header tag. I haven't
        # checked if all of these are necessary.
        ents = css('h5 code') + css('h4 code') + css('h3 code') + css('h2 code')

        ents.each do |node|
          name = node.content.sub(/\(.*\)/, '()')
          id = node.parent['id']
          entries << [name, id, get_name]
        end

        entries
      end
    end
  end
end
