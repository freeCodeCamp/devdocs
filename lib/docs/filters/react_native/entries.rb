module Docs
  class ReactNative
    class EntriesFilter < Docusaurus::EntriesFilter
      REPLACE_TYPES = {
        'The Basics' => 'Getting Started',
        'apis' => 'APIs',
        'components' => 'Components'
      }

      def get_type
        type = super || 'Miscellaneous'
        type = REPLACE_TYPES[type] || type
        type += ": #{name}" if type == 'Components'
        type
      end

      def additional_entries
        css('h3').each_with_object [] do |node, entries|
          subname = node.text
          next if subname.blank? || node.css('code').empty?
          sep = subname.include?('()') ? '.' : '#'
          subname.prepend(name + sep)
          id = node['id']
          entries << [subname, id]
        end
      end
    end
  end
end
