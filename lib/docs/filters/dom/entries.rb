module Docs
  class Dom
    class EntriesFilter < Docs::EntriesFilter
      TYPE_BY_SPEC = {
        'Battery Status'      => 'Battery Status',
        'Canvas '             => 'Canvas',
        'CSS Object Model'    => 'CSS',
        'Device Orientation'  => 'Device Orientation',
        'Encoding'            => 'Encoding',
        'File API'            => 'File',
        'Geolocation'         => 'Geolocation',
        'Media Capture'       => 'Media',
        'Media Source'        => 'Media',
        'Navigation Timing'   => 'Navigation Timing',
        'Network Information' => 'Network Information',
        'Web Audio'           => 'Web Audio',
        'Web Workers'         => 'Web Workers' }

      TYPE_BY_NAME_STARTS_WITH = {
        'Canvas'              => 'Canvas',
        'ChildNode'           => 'Node',
        'console'             => 'Console',
        'CSS'                 => 'CSS',
        'document'            => 'Document',
        'DocumentFragment'    => 'DocumentFragment',
        'DOM'                 => 'DOM',
        'element'             => 'Element',
        'event'               => 'Event',
        'Event'               => 'Event',
        'File'                => 'File',
        'GlobalEventHandlers' => 'GlobalEventHandlers',
        'history'             => 'History',
        'IDB'                 => 'IndexedDB',
        'Location'            => 'Location',
        'navigator'           => 'Navigator',
        'Node'                => 'Node',
        'Notification'        => 'Notification',
        'ParentNode'          => 'Node',
        'Range'               => 'Range',
        'Selection'           => 'Selection',
        'StyleSheet'          => 'CSS',
        'SVG'                 => 'SVG',
        'Touch'               => 'Touch',
        'TreeWalker'          => 'TreeWalker',
        'Uint'                => 'Typed Arrays',
        'URL'                 => 'URL',
        'window'              => 'window',
        'XMLHttpRequest'      => 'XMLHTTPRequest' }

      TYPE_BY_NAME_INCLUDES = {
        'WebGL'  => 'Canvas',
        'Worker' => 'Web Workers' }

      TYPE_BY_NAME_MATCHES = {
        /HTML\w*Element/ => 'Elements' }

      TYPE_BY_HAS_LINK_TO = {
        'DeviceOrientation specification' => 'Device Orientation',
        'File System API'                 => 'File',
        'Typed Array'                     => 'Typed Arrays',
        'WebSocket'                       => 'Web Sockets',
        'Web Audio API'                   => 'Web Audio',
        'XMLHTTPRequest'                  => 'XMLHTTPRequest' }

      def get_name
        name = super
        name.sub! 'Input.', 'HTMLInputElement.'
        name.sub! 'window.navigator', 'navigator'
        # Comment.Comment => Comment.constructor
        name.sub! %r{\A(\w+)\.\1\z}, '\1.constructor' unless name == 'window.window'
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

      def include_default_entry?
        if (node = at_css('.obsolete', '.deprecated')) &&
           (node.inner_html.include?('removed from the Web') ||
            node.inner_html.include?('Try to avoid using it'))
          false
        else
          true
        end
      end
    end
  end
end
