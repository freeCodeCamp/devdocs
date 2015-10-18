module Docs
  class Dom
    class EntriesFilter < Docs::EntriesFilter
      TYPE_BY_SPEC = {
        'Battery Status'      => 'Battery Status',
        'Canvas '             => 'Canvas',
        'CSS Font Loading'    => 'CSS',
        'CSS Object Model'    => 'CSS',
        'Cryptography'        => 'Web Cryptography',
        'Device Orientation'  => 'Device Orientation',
        'Encoding'            => 'Encoding',
        'Encrypted Media Extensions' => 'Encrypted Media',
        'Fetch'               => 'Fetch',
        'File API'            => 'File',
        'Geolocation'         => 'Geolocation',
        'Geometry'            => 'Geometry',
        'Media Capture'       => 'Media',
        'Media Source'        => 'Media',
        'MediaStream'         => 'Media',
        'Navigation Timing'   => 'Navigation Timing',
        'Network Information' => 'Network Information',
        'Push API'            => 'Push',
        'Shadow DOM'          => 'Shadow DOM',
        'Server-Sent Events'  => 'Server-Sent Events',
        'Service Workers'     => 'Service Workers',
        'Web Animations'      => 'Animation',
        'Web Audio'           => 'Web Audio',
        'Web Messaging'       => 'Web Messaging',
        'Web MIDI'            => 'Web MIDI',
        'Web Storage'         => 'Web Storage',
        'Web Workers'         => 'Web Workers',
        'WebGL'               => 'WebGL',
        'WebRTC'              => 'WebRTC',
        'WebVR'               => 'WebVR' }

      TYPE_BY_NAME_STARTS_WITH = {
        'Audio'               => 'Web Audio',
        'Broadcast'           => 'Broadcast Channel',
        'Canvas'              => 'Canvas',
        'CSS'                 => 'CSS',
        'ChildNode'           => 'Node',
        'console'             => 'Console',
        'document'            => 'Document',
        'DocumentFragment'    => 'DocumentFragment',
        'DOM'                 => 'DOM',
        'element'             => 'Element',
        'event'               => 'Event',
        'Event'               => 'Event',
        'Fetch'               => 'Fetch',
        'File'                => 'File',
        'GlobalEventHandlers' => 'GlobalEventHandlers',
        'history'             => 'History',
        'HTML'                => 'Elements',
        'IDB'                 => 'IndexedDB',
        'location'            => 'Location',
        'navigator'           => 'Navigator',
        'MediaQuery'          => 'MediaQuery',
        'Node'                => 'Node',
        'Notification'        => 'Notification',
        'ParentNode'          => 'Node',
        'Push'                => 'Push',
        'Range'               => 'Range',
        'RTC'                 => 'WebRTC',
        'screen'              => 'Screen',
        'Selection'           => 'Selection',
        'Storage'             => 'Web Storage',
        'StyleSheet'          => 'CSS',
        'Stylesheet'          => 'CSS',
        'SVG'                 => 'SVG',
        'timing'              => 'Navigation Timing',
        'Timing'              => 'Navigation Timing',
        'Touch'               => 'Touch',
        'TreeWalker'          => 'TreeWalker',
        'URL'                 => 'URL',
        'window'              => 'Window',
        'Window'              => 'Window',
        'XMLHttpRequest'      => 'XMLHTTPRequest' }

      TYPE_BY_NAME_INCLUDES = {
        'ChildNode'     => 'Node',
        'Crypto'        => 'Web Cryptography',
        'FormData'      => 'XMLHTTPRequest',
        'ImageBitmap'   => 'Canvas',
        'ImageData'     => 'Canvas',
        'IndexedDB'     => 'IndexedDB',
        'Media Source'  => 'Media',
        'MediaStream'   => 'Media',
        'NodeList'      => 'Node',
        'Path2D'        => 'Canvas',
        'Server-sent'   => 'Server-Sent Events',
        'ServiceWorker' => 'Service Workers',
        'TextMetrics'   => 'Canvas',
        'udio'          => 'Web Audio',
        'WebSocket'     => 'Web Sockets',
        'WebGL'         => 'WebGL',
        'WEBGL'         => 'WebGL',
        'WebRTC'        => 'WebRTC',
        'WebVR'         => 'WebVR',
        'Worker'        => 'Web Workers' }

      TYPE_BY_NAME_MATCHES = {}

      TYPE_BY_HAS_LINK_TO = {
        'DeviceOrientation specification' => 'Device Orientation',
        'File System API'                 => 'File',
        'WebSocket'                       => 'Web Sockets',
        'Web Audio API'                   => 'Web Audio',
        'XMLHTTPRequest'                  => 'XMLHTTPRequest' }

      CLEANUP_NAMES = %w(
        CSS\ Object\ Model.
        Web\ Audio\ API.
        IndexedDB\ API.
        MediaRecorder\ API.
        Tutorial.
        XMLHttpRequest.)

      def get_name
        name = super
        CLEANUP_NAMES.each { |str| name.remove!(str) }
        name.sub! 'Input.', 'HTMLInputElement.'
        name.sub! 'window.navigator', 'navigator'
        name.sub! 'API.', 'API: '
        # Comment.Comment => Comment.constructor
        name.sub! %r{\A(\w+)\.\1\z}, '\1.constructor' unless name == 'window.window'
        name.prepend 'XMLHttpRequest.' if slug.start_with?('XMLHttpRequest/') && !name.start_with?('XMLHttpRequest')
        name
      end

      def get_type
        TYPE_BY_NAME_STARTS_WITH.each_pair do |key, value|
          return value if name.start_with?(key)
        end

        TYPE_BY_NAME_INCLUDES.each_pair do |key, value|
          return value if name.include?(key)
        end

        TYPE_BY_NAME_MATCHES.each_pair do |key, value|
          return value if name =~ key
        end

        if spec = css('.standard-table').last
          spec = spec.content
          TYPE_BY_SPEC.each_pair do |key, value|
            return value if spec.include?(key)
          end
        end

        links_text = css('a').map(&:content).join
        TYPE_BY_HAS_LINK_TO.each_pair do |key, value|
          return value if links_text.include?(key)
        end

        if name.include? 'Event'
          'Events'
        else
          'Miscellaneous'
        end
      end

      SKIP_CONTENT = [
        'not on a standards track',
        'removed from the Web',
        'not on a current W3C standards track',
        'This feature is not built into all browsers',
        'not currently supported in any browser'
      ]

      def include_default_entry?
        return true if type == 'Console'
        return true unless node = doc.at_css('.overheadIndicator')
        content = node.content
        SKIP_CONTENT.none? { |str| content.include?(str) }
      end

      def additional_entries
        entries = []

        if slug == 'history' || slug == 'XMLHttpRequest'
          css('dt a[title*="not yet been written"]').each do |node|
            next if node.parent.at_css('.obsolete')
            name = node.content.sub('History', 'history')
            id = node.parent['id'] = name.parameterize
            entries << [name, id]
          end
        end

        if slug == 'XMLHttpRequest'
          css('h2[id="Methods_2"] ~ h3').each do |node|
            break if node.content == 'Non-standard methods'
            entries << ["#{name}.#{node.content}", node['id']]
          end
        end

        entries
      end
    end
  end
end
