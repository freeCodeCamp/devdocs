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

        css('h3 > code, h4 > code, h5 > code').each do |node|

          case node.parent.child.content
          when /Class/
            entries << ["Class #{node.parent['id']}", node.parent['id'], type]
          when /Event/
            entries << ["Event #{node.parent['id']}", node.parent['id'], type]
          end

          if node.parent.child.is_a?(Nokogiri::XML::Text)
            next
          else
            entries << [node.parent['id'], node.parent['id'], type]
          end

        end

        entries
      end

    end
  end
end
