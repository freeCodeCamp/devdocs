module Docs
  class Pytorch
    class EntriesFilter < Docs::EntriesFilter
      def get_breadcrumbs
        breadcrumbs = if at_css('.pytorch-breadcrumbs')
          css('.pytorch-breadcrumbs > li').map { |node|
            node.content.delete_suffix(' >').strip
          }
        else
          css('.bd-breadcrumbs > li').map { |node|
            text = node.content.strip
            text.empty? && node.at_css('.fa-home') ? 'Docs' : text
          }
        end.reject { |item| item.nil? || item.empty? }

        if breadcrumbs.last&.end_with?('.')
          resolved_name = at_css('h1').content.delete_suffix('#').strip
          breadcrumbs[-1] = resolved_name
        end

        breadcrumbs
      end

      def get_name
        get_breadcrumbs[-1]
      end

      def get_type
        if at_css('.pytorch-breadcrumbs')
          get_breadcrumbs[1]
        else
          get_breadcrumbs.size > 2 ? get_breadcrumbs[2] : get_breadcrumbs[1]
        end
      end

      def include_default_entry?
        !get_breadcrumbs.nil? && get_breadcrumbs.size >= 2
      end

      def additional_entries
        return [] if root_page?

        entries = []
        css('dl').each do |node|
          dt = node.at_css('dt')
          if dt == nil
            next
          end
          id = dt['id']
          if id == name or id == nil
            next
          end

          case node['class']
          when 'py method', 'py function'
            entries << [id + '()', id]
          when 'py class', 'py attribute', 'py property'
            entries << [id, id]
          end
        end

        entries
      end
    end
  end
end
