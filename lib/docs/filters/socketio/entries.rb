module Docs
  class Socketio
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        if slug =~ /events|room|emit/ && !version.eql?('2')
          'Events'
        else
          'Guides'
        end
      end

      def additional_entries
        return [] unless slug.end_with?('api')

        css('h3').each_with_object([]) do |node, entries|
          name = node.content

          entries << [name, node['id'], self.name.remove(' API')]
        end
      end
    end
  end
end
