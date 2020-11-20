module Docs
  class Pytorch
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        # retrive the name in breadcrumb from the auxiliary node
        name_in_breadcrumb = doc.child.content
        doc.child.remove

        # hard-coded name replacements, for better presentation.
        name_replacements = {
          "Distributed communication package - torch.distributed" => "torch.distributed"
        }

        # The id of the container `div.section` indicates the page type.
        # If the id starts with `module-`, then it's an API reference,
        # otherwise it is a note or design doc.
        # After the `sphinx/clean_html` filter, that id is assigned to the second element.
        if doc.element_children[1]['id']&.starts_with? 'module-'
          /\Amodule-(.*)/.match(doc.element_children[1]['id'])[1]
        else
          name_in_breadcrumb = name_in_breadcrumb.delete_suffix(' >')
          name_in_breadcrumb = name_replacements.fetch(name_in_breadcrumb, name_in_breadcrumb)
          name_in_breadcrumb
        end
      end

      def get_type
        name
      end

      def include_default_entry?
        # Only include API references, and ignore notes or design docs
        !subpath.start_with? 'generated/' and type.start_with? 'torch'
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
