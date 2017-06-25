module Docs
  class Julia
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        if slug.start_with?('manual')
          'Manual'
        else
          name
        end
      end

      def additional_entries
        return [] unless slug.start_with?('stdlib')

        css('.docstring-binding[id]').map do |node|
          name = node.content
          name.gsub! '.:', '.'
          name.remove! 'Base.'
          category = node.parent.at_css('.docstring-category').content
          name << '()' if category == 'Function' || category == 'Method'
          [name, node['id']]
        end
      end
    end
  end
end
