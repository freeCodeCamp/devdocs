module Docs
  class Svelte
    class EntriesFilter < Docs::EntriesFilter
      def get_type
        'Svelte'
      end

      def additional_entries
        type = 'Svelte'
        subtype = nil
        css('h2, h3, h4').each_with_object [] do |node, entries|
          if node.name == 'h2'
            type = node.content.strip
            subtype = nil
          elsif node.name == 'h3'
            subtype = node.content.strip
            subtype = nil unless subtype[/Component directives|Element directives/]
          end
          next if type == 'Before we begin'
          name = node.content.strip
          name.concat " (#{subtype})" if subtype && node.name == 'h4'
          entries << [name, node['id'], subtype || type]
        end
      end
    end
  end
end
