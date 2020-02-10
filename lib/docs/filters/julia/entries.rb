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
        return [] if slug.start_with?('manual')

        entries = []
        used_names = {}

        css('.docstring-binding[id]').each do |node|
          name = node.content
          name.gsub! '.:', '.'
          name.remove! 'Base.'
          category = node.parent.at_css('.docstring-category').content
          name << '()' if category == 'Function' || category == 'Method'

          entries << [name, node['id']] unless used_names.key?(name)
          used_names[name] = true
        end

        entries
      end
    end
  end
end
