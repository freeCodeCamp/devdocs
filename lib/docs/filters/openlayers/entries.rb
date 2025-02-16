module Docs
  class Openlayers
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h2').text.split('~').last.strip
      end

      def get_type
        slug[/ol_([^_]+)_/, 1] or 'ol'
      end

      def additional_entries
        css('h4.name').each_with_object [] do |node, entries|
          node['id'] = node.previous_element['id']
          next if node.at_css('.inherited')
          name = node.children.find {|n| n.text? }.text.strip
          name.prepend "#{self.name}."
          entries << [name, node['id']]
        end
      end
    end
  end
end
