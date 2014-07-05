module Docs
  class Cordova
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content.remove(' Guide')
      end

      def get_type
        if subpath.start_with?('guide_platforms')
          name[/Amazon\ Fire\ OS|Android|BlackBerry|Firefox OS|iOS|Windows/] || 'Platform Guides'
        else
          'Guides'
        end
      end

      def additional_entries
        return [] unless slug == 'cordova_events_events.md'

        css('h2').map do |node|
          [node.content, node['id'], 'Events']
        end
      end
    end
  end
end
