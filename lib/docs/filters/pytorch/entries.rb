module Docs
  class Pytorch
    class EntriesFilter < Docs::EntriesFilter
      def get_breadcrumbs
        css('.pytorch-breadcrumbs > li').map {
          |node| node.content.delete_suffix(' >').strip
        }.reject { |item| item.nil? || item.empty? }
      end

      def get_name
        get_breadcrumbs[-1]
      end

      def get_type
        get_breadcrumbs[1]
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
