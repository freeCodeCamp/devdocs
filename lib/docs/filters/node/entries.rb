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
        css('h3 > code, h4 > code, h5 > code, h6 > code').each_with_object [] do |node, entries|
          name = node.content.gsub(/\(.*\)/, '()')
          id = node.parent['id']

          case node.parent.child.content
          when /Class/
            entries << ["Class #{name}", id, type]
          when /Event/
            entries << ["Event #{name}", id, type]
          end

          if node.parent.child.is_a?(Nokogiri::XML::Text) && !node.parent.child.content.include?('Static method:')
            next
          elsif entries.select {|entry| entry[0] == name}.first
            entries << [node.content, id, type]
          else
            entries << [name, id, type]
          end

        end
      end

    end
  end
end
