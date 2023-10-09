module Docs
  class Svelte
    class EntriesFilter < Docs::EntriesFilter
      def get_type
        at_css('ul.sidebar > li:has(.active) > span.section').content
      end

      def additional_entries
        subtype = nil
        css('aside').remove
        css('.category').remove
        css('.controls').remove
        css('.edit').remove
        css('.permalink').remove
        css('h2, h3, h4').each_with_object [] do |node, entries|
          if node.name == 'h2'
            subtype = nil
          elsif node.name == 'h3'
            subtype = node.content.strip
            subtype = nil unless subtype[/Component directives|Element directives/]
          end
          next if type == 'Before we begin'
          name = node.content.strip
          name.concat " (#{subtype})" if subtype && node.name == 'h4'
          next if name.starts_with?('Example')
          entries << [name, node['id'], get_type]
        end
      end
    end
  end
end
