module Docs
  class Node
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        type
      end

      def get_type
        at_css('h2').content.strip
      end

      def additional_entries
        entries = []

        css('h3 > code, h4 > code, h5 > code, h6 > code').each do |node|
          name = node.content.gsub(/\(.*\)/, '()')
          id = node.parent['id']

          case node.parent.child.content
          when /Class/
            entries << ["Class #{name}", id, type]
          when /Event/
            entries << ["Event #{name}", id, type]
          end

          if node.parent.child.is_a?(Nokogiri::XML::Text)
            next
          else
            entries << [name, id, type]
          end

        end

        entries
      end

    end
  end
end
