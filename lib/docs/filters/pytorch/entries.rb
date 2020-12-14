module Docs
  class Pytorch
    class EntriesFilter < Docs::EntriesFilter
      NAME_REPLACEMENTS = {
        "Distributed communication package - torch.distributed" => "torch.distributed"
      }

      def get_breadcrumbs()
        css('.pytorch-breadcrumbs > li').map { |node| node.content.delete_suffix(' >') }
      end

      def get_name
        # The id of the container `div.section` indicates the page type.
        # If the id starts with `module-`, then it's an API reference,
        # otherwise it is a note or design doc.
        section_id = at_css('.section')['id']
        if section_id.starts_with? 'module-'
          section_id.remove('module-')
        else
          name = get_breadcrumbs()[1]
          NAME_REPLACEMENTS.fetch(name, name)
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
