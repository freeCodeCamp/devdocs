module Docs
  class Php
    class EntriesFilter < Docs::EntriesFilter
      TYPES = {
      # [name-begin-with]   => [type]
        'AMQP'              => 'AMQP',
        'APCIterator'       => 'APC',
        'CURL'              => 'cURL',
        'Date'              => 'Date and Time',
        'DirectoryIterator' => 'Standard PHP Library',
        'Directory'         => 'Directories',
        'DOM'               => 'DOM',
        'Gearman'           => 'Gearman',
        'Gmagick'           => 'Gmagick',
        'Http'              => 'HTTP',
        'Imagick'           => 'Imagick',
        'Collator'          => 'Internationalization',
        'NumberFormatter'   => 'Internationalization',
        'Locale'            => 'Internationalization',
        'MessageFormatter'  => 'Internationalization',
        'Normalizer'        => 'Internationalization',
        'Intl'              => 'Internationalization',
        'intl'              => 'Internationalization',
        'ResourceBundle'    => 'Internationalization',
        'Spoofchecker'      => 'Internationalization',
        'Transliterator'    => 'Internationalization',
        'UConverter'        => 'Internationalization',
        'grapheme'          => 'Internationalization',
        'idn'               => 'Internationalization',
        'Json'              => 'JSON',
        'mysqli'            => 'mysqli',
        'OAuth'             => 'OAuth',
        'PDO'               => 'PDO',
        'Thread'            => 'pthreads',
        'Worker'            => 'pthreads',
        'Stackable'         => 'pthreads',
        'Mutex'             => 'pthreads',
        'Cond'              => 'pthreads',
        'Exception'         => 'Predefined Exceptions',
        'ErrorException'    => 'Predefined Exceptions',
        'QuickHash'         => 'QuickHash',
        'Reflection'        => 'Reflection',
        'Reflector'         => 'Reflection',
        'Session'           => 'Sessions',
        'SimpleXML'         => 'SimpleXML',
        'Soap'              => 'SOAP',
        'Solr'              => 'Solr',
        'Sphinx'            => 'Sphinx',
        'Spl'               => 'Standard PHP Library',
        'ArrayObject'       => 'Standard PHP Library',
        'Countable'         => 'Standard PHP Library',
        'SQLite3'           => 'SQLite3',
        'streamWrapper'     => 'Streams',
        'php_user_filter'   => 'Streams',
        'tidy'              => 'Tidy',
        'V8Js'              => 'V8js',
        'Varnish'           => 'Varnish',
        'Weakref'           => 'Weak References',
        'WeakRef'           => 'Weak References',
        'WeakMap'           => 'Weak References',
        'XSLTProcessor'     => 'XSLT',
        'XsltProcessor'     => 'XSLT',
        'Yaf'               => 'Yaf',
        'ZipArchive'        => 'Zip' }

      REPLACE_TYPES = {
      # [original-type]     => [new-type]
        'Array'             => 'Arrays',
        'Bzip2'             => 'bzip2',
        'Classes/Object'    => 'Classes and Objects',
        'Date/Time'         => 'Date and Time',
        'Directory'         => 'Directories',
        'Exceptions'        => 'Standard PHP Library',
        'Function handling' => 'Function Handling',
        'GD and Image'      => 'GD',
        'Gettext'           => 'gettext',
        'Inotify'           => 'inotify',
        'Interfaces'        => 'Standard PHP Library',
        'Iterators'         => 'Standard PHP Library',
        'Libevent'          => 'libevent',
        'Mailparse'         => 'Mail',
        'Misc.'             => 'Miscellaneous',
        'Multibyte String'  => 'Multibyte Strings',
        'PCRE'              => 'Regular Expressions',
        'PHP Options/Info'  => 'Options and Info',
        'POSIX Regex'       => 'Regular Expressions',
        'Program execution' => 'Program Execution',
        'Session'           => 'Sessions',
        'Session PgSQL'     => 'PostgreSQL',
        'SPL'               => 'Standard PHP Library',
        'Statistic'         => 'Statistics',
        'Stream'            => 'Streams',
        'String'            => 'Strings',
        'Variable handling' => 'Variable Handling',
        'XMLReader'         => 'XML Reader',
        'XMLWriter'         => 'XML Writer',
        'Yaml'              => 'YAML',
        'Zlib'              => 'zlib' }

      IGNORE_SLUGS = %w(reserved.exceptions reserved.interfaces
        reserved.variables)

      def include_default_entry?
        !(slug.start_with?('book') || IGNORE_SLUGS.include?(slug))
      end

      def get_name
        name = css('> .sect1 > .title', 'h1', 'h2').first.content

        if name == 'Exception class for intl errors'
          'IntlException'
        else
          name.sub! 'The ', ''
          name.sub! ' class', ' (class)'
          name.sub! ' interface', ' (interface)'
          name
        end
      end

      def get_type
        if key = TYPES.keys.detect { |t| name.start_with?(t) }
          TYPES[key]
        else
          type = at_css('.up').content.strip
          type.sub! ' Functions', ''
          type.sub! ' Obsolete Aliases and', ''

          if type.end_with? 'Iterator'
            'Standard PHP Library'
          else
            REPLACE_TYPES[type] || type
          end
        end
      end
    end
  end
end
