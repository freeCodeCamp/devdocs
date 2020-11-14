module Docs
  class Pytorch
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        # The id of the container `div.section` indicates the page type.
        # If the id starts with `module-`, then it's an API reference,
        # otherwise it is a note or design doc.
        # After the `sphinx/clean_html` filter, that id is assigned to the second element.
        if doc.element_children[1]['id']&.starts_with? 'module-'
          /\Amodule-(.*)/.match(doc.element_children[1]['id'])[1]
        else
          at_css('h1').content
        end
      end

      def get_type
        name
      end

      def include_default_entry?
        # If the page is not an API reference, we only include it in the index when it
        # contains additional entries. See the doc for `get_name`.
        doc.element_children[1]['id']&.starts_with? 'module-'
      end

      def additional_entries
        return [] if root_page?

        entries = []

        css('dt').each do |node|
          name = node['id']
          if name == self.name or name == nil
            next
          end

          case node.parent['class']
          when 'method', 'function'
            if node.at_css('code').content.starts_with? 'property '
              # this instance method is a property, so treat it as an attribute
              entries << [name, node['id']]
            else
              entries << [name + '()', node['id']]
            end
          when 'class', 'attribute'
            entries << [name, node['id']]
          end
        end

        entries
      end
    end
  end
end
