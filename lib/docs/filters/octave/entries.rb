module Docs
  class Octave
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content.sub(/(A?[0-9.]+ )/, '')
      end

      def get_type
        return 'Manual: Appendices' if name.start_with?('Appendix')
        return 'Manual: Indexes' if name.end_with?('Index')
        'Manual'
      end

      def additional_entries
        css('dl:not([compact]) > dt').each_with_object [] do |node, entries|
          name = node.content.gsub(/[A-z0-9\,… ]*\=/, '').strip.split(' ')[0]
          entries << [name, node['id'], 'Functions'] unless node['id'] =~ /-\d+\Z/
        end
      end
    end
  end
end
