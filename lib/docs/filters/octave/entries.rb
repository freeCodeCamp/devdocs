module Docs
  class Octave
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        'Manual'
      end

      def additional_entries
        css('dl:not([compact]) > dt').each_with_object [] do |node, entries|
          name = node.content.gsub(/[A-z0-9\,… ]*\=/,'').strip
          entries << [name, node['id'], 'Functions']
        end
      end
    end
  end
end
