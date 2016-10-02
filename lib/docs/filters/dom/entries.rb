module Docs
  class Dom
    class EntriesFilter < Docs::EntriesFilter
      TYPE_BY_SPEC = {
        'ANGLE_'              => 'WebGL',
        'EXT_'                => 'WebGL',
        'OES_'                => 'WebGL',
        'WEBGL_'              => 'WebGL',
        'Battery Status'      => 'Battery Status',
        'Canvas '             => 'Canvas',
        'CSS Font Loading'    => 'CSS',
        'CSS Object Model'    => 'CSS',
        'Credential'          => 'Credential Management',
        'Cryptography'        => 'Web Cryptography',
        'Device Orientation'  => 'Device Orientation',
        'Encoding'            => 'Encoding',
        'Encrypted Media Extensions' => 'Encrypted Media',
        'Fetch'               => 'Fetch',
        'File API'            => 'File',
        'Geolocation'         => 'Geolocation',
        'Geometry'            => 'Geometry',
        'High Resolution Time' => 'Web Performance',
        'Intersection'        => 'Intersection Observer',
        'Media Capture'       => 'Media',
        'Media Source'        => 'Media',
        'MediaStream'         => 'Media Streams',
        'Navigation Timing'   => 'Web Performance',
        'Network Information' => 'Network Information',
        'Payment Request'     => 'Payment Request',
        'Performance Timeline' => 'Web Performance',
        'Pointer Events'      => 'Pointer Events',
        'Push API'            => 'Push',
        'Presentation API'    => 'Presentation',
        'Shadow DOM'          => 'Shadow DOM',
        'Server-Sent Events'  => 'Server-Sent Events',
        'Service Workers'     => 'Service Workers',
        'Stream API'          => 'Media Streams',
        'Streams'             => 'Media Streams',
        'Touch Events'        => 'Touch Events',
        'Web Animations'      => 'Animation',
        'Web App Manifest'    => 'Web App Manifest',
        'Web Audio'           => 'Web Audio',
        'Web Messaging'       => 'Web Messaging',
        'Web MIDI'            => 'Web MIDI',
        'Web Speech'          => 'Web Speech',
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
        'DataTransfer'        => 'Drag & Drop',
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
        'HTML Drag'           => 'Drag & Drop',
        'HTML'                => 'Elements',
        'IDB'                 => 'IndexedDB',
        'location'            => 'Location',
        'navigator'           => 'Navigator',
        'MediaQuery'          => 'MediaQuery',
        'MediaTrack'          => 'Media Streams',
        'Node'                => 'Node',
        'Notification'        => 'Notification',
        'OffscreenCanvas'     => 'Canvas',
        'ParentNode'          => 'Node',
        'Performance'         => 'Web Performance',
        'Presentation'        => 'Presentation',
        'Push'                => 'Push',
        'Range'               => 'Range',
        'Resource Timing'     => 'Web Performance',
        'RTC'                 => 'WebRTC',
        'screen'              => 'Screen',
        'Selection'           => 'Selection',
        'Storage'             => 'Web Storage',
        'StyleSheet'          => 'CSS',
        'Stylesheet'          => 'CSS',
        'SVG'                 => 'SVG',
        'timing'              => 'Web Performance',
        'Timing'              => 'Web Performance',
        'Touch'               => 'Touch Events',
        'TreeWalker'          => 'TreeWalker',
        'URL'                 => 'URL',
        'VR'                  => 'WebVR',
        'window'              => 'Window',
        'Window'              => 'Window',
        'XMLHttpRequest'      => 'XMLHTTPRequest' }

      TYPE_BY_NAME_INCLUDES = {
        'Animation'     => 'Animation',
        'ChildNode'     => 'Node',
        'Crypto'        => 'Web Cryptography',
        'Drag'          => 'Drag & Drop',
        'FormData'      => 'XMLHTTPRequest',
        'History'       => 'History',
        'ImageBitmap'   => 'Canvas',
        'ImageData'     => 'Canvas',
        'IndexedDB'     => 'IndexedDB',
        'Media Source'  => 'Media',
        'MediaStream'   => 'Media Streams',
        'Media Streams' => 'Media Streams',
        'NodeList'      => 'Node',
        'Path2D'        => 'Canvas',
        'Pointer'       => 'Pointer Events',
        'Server-sent'   => 'Server-Sent Events',
        'ServiceWorker' => 'Service Workers',
        'Speech'        => 'Web Speech',
        'TextMetrics'   => 'Canvas',
        'timing'        => 'Web Performance',
        'Timing'        => 'Web Performance',
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
        XMLHttpRequest.
        ANGLE\ instanced\ arrays.)

      def get_name
        name = super
        CLEANUP_NAMES.each { |str| name.remove!(str) }
        name.sub! 'Input.', 'HTMLInputElement.'
        name.sub! 'window.navigator', 'navigator'
        name.sub! 'API.', 'API: '
        name.sub! %r{\A(ANGLE|EXT|OES|WEBGL)[\w\ ]+\.}, 'ext.'
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
        node = node.parent while node.parent != doc
        return true if node.previous_element.try(:name).in?(%w(h2 h3))
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

        if slug == 'History_API'
          entries << ['history.pushState()', 'The_pushState()_method']
        end

        entries
      end
    end
  end
end
