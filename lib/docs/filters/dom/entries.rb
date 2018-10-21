module Docs
  class Dom
    class EntriesFilter < Docs::EntriesFilter
      TYPE_BY_SPEC = {
        'ANGLE_'              => 'WebGL',
        'EXT_'                => 'WebGL',
        'OES_'                => 'WebGL',
        'WEBGL_'              => 'WebGL',
        'Ambient Light'       => 'Ambient Light',
        'Audio'               => 'Audio',
        'Battery Status'      => 'Battery Status',
        'Canvas '             => 'Canvas',
        'Clipboard'           => 'Clipboard',
        'Content Security'    => 'Content Security Policy',
        'Cooperative Scheduling' => 'Scheduling',
        'CSS Font Loading'    => 'CSS',
        'CSS Object Model'    => 'CSS',
        'Credential'          => 'Credential Management',
        'Cryptography'        => 'Cryptography',
        'Device Orientation'  => 'Device Orientation',
        'Encoding'            => 'Encoding',
        'Encrypted Media Extensions' => 'Encrypted Media',
        'Fetch'               => 'Fetch',
        'File API'            => 'File',
        'Geolocation'         => 'Geolocation',
        'Geometry'            => 'Geometry',
        'High Resolution Time' => 'Performance',
        'Intersection'        => 'Intersection Observer',
        'Media Capabilities'  => 'Media',
        'Media Capture'       => 'Media',
        'Media Session'       => 'Media',
        'Media Source'        => 'Media',
        'MediaError'          => 'Media',
        'MediaStream'         => 'Media Streams',
        'MIDI'                => 'Audio',
        'Navigation Timing'   => 'Performance',
        'Network Information' => 'Network Information',
        'Payment'             => 'Payments',
        'Performance Timeline' => 'Performance',
        'Pointer Events'      => 'Pointer Events',
        'Push API'            => 'Push',
        'Presentation API'    => 'Presentation',
        'Shadow DOM'          => 'Shadow DOM',
        'Server-Sent Events'  => 'Server-Sent Events',
        'Service Workers'     => 'Service Workers',
        'Speech'              => 'Speech',
        'Storage'             => 'Storage',
        'Stream API'          => 'Media Streams',
        'Streams'             => 'Media Streams',
        'Touch Events'        => 'Touch Events',
        'Visual Viewport'     => 'Visual Viewport',
        'Web Animations'      => 'Animation',
        'Web App Manifest'    => 'Web App Manifest',
        'Budget'              => 'Budget',
        'Web Authentication'  => 'Authentication',
        'Web Workers'         => 'Web Workers',
        'WebGL'               => 'WebGL',
        'WebRTC'              => 'WebRTC',
        'WebUSB'              => 'WebUSB',
        'WebVR'               => 'WebVR' }

      TYPE_BY_NAME_STARTS_WITH = {
        'AbortController'     => 'Fetch',
        'AbortSignal'         => 'Fetch',
        'Ambient'             => 'Ambient Light',
        'Attr'                => 'Nodes',
        'Audio'               => 'Audio',
        'BasicCard'           => 'Payments',
        'Broadcast'           => 'Broadcast Channel',
        'Budget'              => 'Budget',
        'Canvas'              => 'Canvas',
        'Clipboard'           => 'Clipboard',
        'CSS'                 => 'CSS',
        'CharacterData'       => 'Nodes',
        'ChildNode'           => 'Nodes',
        'Comment'             => 'Nodes',
        'console'             => 'Console',
        'CustomElement'       => 'Custom Elements',
        'DataTransfer'        => 'Drag & Drop',
        'document'            => 'Document',
        'Document Object'     => 'DOM',
        'DocumentFragment'    => 'DocumentFragment',
        'DocumentType'        => 'Nodes',
        'DOM'                 => 'DOM',
        'element'             => 'Element',
        'event'               => 'Event',
        'Event'               => 'Event',
        'EventSource'         => 'Server-Sent Events',
        'Fetch'               => 'Fetch',
        'File'                => 'File',
        'GlobalEventHandlers' => 'GlobalEventHandlers',
        'history'             => 'History',
        'HTML Drag'           => 'Drag & Drop',
        'HTML'                => 'Elements',
        'IDB'                 => 'IndexedDB',
        'location'            => 'Location',
        'navigator'           => 'Navigator',
        'MediaKeySession'     => 'Encrypted Media',
        'MediaMetadata'       => 'Media Session',
        'MediaSession'        => 'Media Session',
        'MediaTrack'          => 'Media Streams',
        'Message'             => 'Channel Messaging',
        'Mutation'            => 'DOM',
        'NamedNode'           => 'Nodes',
        'Node'                => 'Nodes',
        'Notification'        => 'Notification',
        'OffscreenCanvas'     => 'Canvas',
        'ParentNode'          => 'Nodes',
        'Performance'         => 'Performance',
        'Presentation'        => 'Presentation',
        'Push'                => 'Push',
        'Range'               => 'Range',
        'RenderingContext'    => 'Canvas',
        'Resource Timing'     => 'Performance',
        'RTC'                 => 'WebRTC',
        'screen'              => 'Screen',
        'Selection'           => 'Selection',
        'Shadow'              => 'Shadow DOM',
        'StaticRange'         => 'Range',
        'Streams'             => 'Media Streams',
        'StyleProperty'       => 'CSS',
        'StyleSheet'          => 'CSS',
        'Stylesheet'          => 'CSS',
        'SVG'                 => 'SVG',
        'TimeRanges'          => 'Media',
        'timing'              => 'Performance',
        'Timing'              => 'Performance',
        'Touch'               => 'Touch Events',
        'TreeWalker'          => 'TreeWalker',
        'URL'                 => 'URL',
        'VR'                  => 'WebVR',
        'WebSocket'           => 'Web Sockets',
        'USB'                 => 'WebUSB',
        'window'              => 'Window',
        'Window'              => 'Window',
        'XMLHttpRequest'      => 'XMLHTTPRequest' }

      TYPE_BY_NAME_INCLUDES = {
        'Animation'     => 'Animation',
        'ChildNode'     => 'Nodes',
        'Crypto'        => 'Cryptography',
        'Drag'          => 'Drag & Drop',
        'FormData'      => 'XMLHTTPRequest',
        'History'       => 'History',
        'ImageBitmap'   => 'Canvas',
        'ImageData'     => 'Canvas',
        'IndexedDB'     => 'IndexedDB',
        'Media Source'  => 'Media',
        'MediaStream'   => 'Media Streams',
        'Media Streams' => 'Media Streams',
        'Messaging'     => 'Channel Messaging',
        'NodeList'      => 'Nodes',
        'Path2D'        => 'Canvas',
        'Pointer'       => 'Pointer Events',
        'Server-sent'   => 'Server-Sent Events',
        'ServiceWorker' => 'Service Workers',
        'Speech'        => 'Speech',
        'Storage'       => 'Storage',
        'TextMetrics'   => 'Canvas',
        'timing'        => 'Performance',
        'Timing'        => 'Performance',
        'udio'          => 'Audio',
        'WebGL'         => 'WebGL',
        'WEBGL'         => 'WebGL',
        'WebRTC'        => 'WebRTC',
        'WebVR'         => 'WebVR',
        'Worker'        => 'Web Workers' }

      TYPE_BY_NAME_MATCHES = {
        /\AText(\z|\.)/ => 'Nodes'
      }

      TYPE_BY_HAS_LINK_TO = {
        'DeviceOrientation specification' => 'Device Orientation',
        'File System API'                 => 'File',
        'WebSocket'                       => 'Web Sockets',
        'Web Audio API'                   => 'Audio',
        'XMLHTTPRequest'                  => 'XMLHTTPRequest' }

      CLEANUP_NAMES = %w(
        CSS\ Object\ Model.
        Tutorial.
        XMLHttpRequest.
        ANGLE\ instanced\ arrays.)

      def get_name
        name = super
        CLEANUP_NAMES.each { |str| name.remove!(str) }
        name.sub! %r{Document\ Object\ Model\.}i, 'Document Object Model: '
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
          css('dt a[href^="https://developer.mozilla.org"]').each do |node|
            next if node.parent.at_css('.obsolete') || node.content.include?('moz')
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
