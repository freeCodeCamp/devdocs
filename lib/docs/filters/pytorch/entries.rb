module Docs
  class Pytorch
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        breadcrumbs = at_css('.pytorch-breadcrumbs')
        name_in_breadcrumb = breadcrumbs.css('li')[1].content

        article = at_css('.pytorch-article')

        # hard-coded name replacements, for better presentation.
        name_replacements = {
          "Distributed communication package - torch.distributed" => "torch.distributed"
        }

        # The id of the container `div.section` indicates the page type.
        # If the id starts with `module-`, then it's an API reference,
        # otherwise it is a note or design doc.
        article_id = article.at_css('div.section')['id']
        if article_id.starts_with? 'module-'
          /\Amodule-(.*)/.match(article_id)[1]
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
