module Docs
  class DomEvents
    class EntriesFilter < Docs::EntriesFilter
      TYPE_BY_INFO = {
        'applicationCache' => 'Application Cache',
        'Battery'          => 'Battery',
        'Call'             => 'Telephony',
        'Clipboard'        => 'Clipboard',
        'CSS'              => 'CSS',
        'Drag'             => 'Drag & Drop',
        'Fetch'            => 'Fetch',
        'Fullscreen'       => 'Fullscreen',
        'Gamepad'          => 'Gamepad',
        'HashChange'       => 'History',
        'IDB'              => 'IndexedDB',
        'IndexedDB'        => 'IndexedDB',
        'Keyboard'         => 'Keyboard',
        'edia'             => 'Media',
        'Mouse'            => 'Mouse',
        'Notification'     => 'Notification',
        'Offline'          => 'Offline',
        'Orientation'      => 'Device',
        'Sensor'           => 'Device',
        'SVG'              => 'SVG',
        'Page Visibility'  => 'Page Visibility',
        'Pointer'          => 'Mouse',
        'PopState'         => 'History',
        'Push'             => 'Push',
        'Progress'         => 'Progress',
        'Proximity'        => 'Device',
        'Selection'        => 'Selection',
        'Server Sent'      => 'Server Sent Events',
        'Speech'           => 'Web Speech',
        'Storage'          => 'Web Storage',
        'Touch'            => 'Touch',
        'Transition'       => 'CSS',
        'PageTransition'   => 'History',
        'WebSocket'        => 'WebSocket',
        'Web App Manifest' => 'Web App Manifest',
        'Web Audio'        => 'Web Audio',
        'Web Messaging'    => 'Web Messaging',
        'WebGL'            => 'WebGL',
        'WebRTC'           => 'WebRTC',
        'WebVR'            => 'WebVR',
        'Wheel'            => 'Mouse',
        'Worker'           => 'Web Workers',
        'Focus'            => 'Focus' }

      FORM_SLUGS = %w(change compositionend compositionstart compositionupdate
        input invalid reset select submit)
      LOAD_SLUGS = %w(abort beforeunload DOMContentLoaded error load
        readystatechange unload)

      APPEND_TYPE = %w(Application\ Cache IndexedDB Progress Telephony
        Server\ Sent\ Events WebSocket Web\ Messaging Web\ Workers)

      def get_name
        name = super
        name = "#{name.split.first} (#{type})" if APPEND_TYPE.include?(type)
        name
      end

      def get_type
        if FORM_SLUGS.include?(slug)
          'Form'
        elsif LOAD_SLUGS.include?(slug)
          'Load'
        else
          info = css('.eventinfo, .properties, .standard-table').map(&:content).join
          TYPE_BY_INFO.each_pair do |key, value|
            return value if info.include?(key)
          end

          'Miscellaneous'
        end
      end

      def include_default_entry?
        content = doc.content
        !content.include?('Firefox OS specific') &&
        !content.include?('Addons specific') &&
        !content.include?('Mozilla specific') &&
        content !~ /Specification\s+XUL/
      end
    end
  end
end
