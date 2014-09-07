module Docs
  class DomEvents
    class EntriesFilter < Docs::EntriesFilter
      TYPE_BY_INFO = {
        'applicationCache' => 'Application Cache',
        'Clipboard'        => 'Clipboard',
        'CSS'              => 'CSS',
        'Drag'             => 'Drag & Drop',
        'Focus'            => 'Focus',
        'Fullscreen'       => 'Fullscreen',
        'HashChange'       => 'History',
        'IndexedDB'        => 'IndexedDB',
        'Keyboard'         => 'Keyboard',
        'edia'             => 'Media',
        'Mouse'            => 'Mouse',
        'Offline'          => 'Offline',
        'Orientation'      => 'Device',
        'Sensor'           => 'Device',
        'Page Visibility'  => 'Page Visibility',
        'Pointer'          => 'Mouse',
        'PopState'         => 'History',
        'Progress'         => 'Progress',
        'Proximity'        => 'Device',
        'Server Sent'      => 'Server Sent Events',
        'Storage'          => 'Web Storage',
        'Touch'            => 'Touch',
        'Transition'       => 'CSS',
        'PageTransition'   => 'History',
        'WebSocket'        => 'WebSocket',
        'Web Audio'        => 'Web Audio',
        'Web Messaging'    => 'Web Messaging',
        'Wheel'            => 'Mouse',
        'Worker'           => 'Web Workers' }

      FORM_SLUGS = %w(change compositionend compositionstart compositionupdate
        input invalid reset select submit)
      LOAD_SLUGS = %w(abort beforeunload DOMContentLoaded error load
        readystatechange unload)

      APPEND_TYPE = %w(Application\ Cache IndexedDB Progress
        Server\ Sent\ Events WebSocket Web\ Messaging Web\ Workers)

      def get_name
        name = super.split.first
        name << " (#{type})" if APPEND_TYPE.include?(type)
        name
      end

      def get_type
        if FORM_SLUGS.include?(slug)
          'Form'
        elsif LOAD_SLUGS.include?(slug)
          'Load'
        else
          if info = at_css('.eventinfo').try(:content)
            TYPE_BY_INFO.each_pair do |key, value|
              return value if info.include?(key)
            end
          end

          'Miscellaneous'
        end
      end
    end
  end
end
