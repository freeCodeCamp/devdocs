module Docs
  class Cordova
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content.remove(' Guide')
      end

      def get_type
        if subpath.start_with?('guide/platforms')
          name[/Amazon\ Fire\ OS|Android|BlackBerry|Firefox OS|iOS|Windows/] || 'Platform Guides'
        elsif subpath.start_with?('cordova/events')
          'Events'
        else
          'Guides'
        end
      end
    end
  end
end
