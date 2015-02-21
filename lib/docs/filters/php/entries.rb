module Docs
  class Php
    class EntriesFilter < Docs::EntriesFilter
      TYPE_BY_NAME_STARTS_WITH = {
        'ArrayObject'     => 'SPL',
        'Collectable'     => 'pthreads',
        'Cond'            => 'pthreads',
        'CURL'            => 'cURL',
        'Date'            => 'Date/Time',
        'ErrorException'  => 'Predefined Exceptions',
        'Exception'       => 'Predefined Exceptions',
        'Json'            => 'JSON',
        'Http'            => 'HTTP',
        'Mutex'           => 'pthreads',
        'php_user_filter' => 'Stream',
        'Pool'            => 'pthreads',
        'Reflector'       => 'Reflection',
        'Soap'            => 'SOAP',
        'SplFile'         => 'SPL/File',
        'SplTempFile'     => 'SPL/File',
        'Spl'             => 'SPL',
        'Stackable'       => 'pthreads',
        'streamWrapper'   => 'Stream',
        'Thread'          => 'pthreads',
        'tidy'            => 'Tidy',
        'Worker'          => 'pthreads',
        'XsltProcessor'   => 'XSLT',
        'ZipArchive'      => 'Zip' }

      %w(APC Directory DOM Event Gearman Gmagick Imagick mysqli OAuth PDO Reflection
        Session SimpleXML Solr Sphinx SQLite3 Varnish XSLT Yaf).each do |str|
        TYPE_BY_NAME_STARTS_WITH[str] = str
      end

      %w(ArrayAccess Closure Generator Iterator IteratorAggregate Serializable Traversable).each do |str|
        TYPE_BY_NAME_STARTS_WITH[str] = 'Predefined Interfaces and Classes'
      end

      %w(Collator grapheme idn Intl intl Locale MessageFormatter Normalizer
         NumberFormatter ResourceBundle Spoofchecker Transliterator UConverter).each do |str|
        TYPE_BY_NAME_STARTS_WITH[str] = 'Internationalization'
      end

      %w(Countable OuterIterator RecursiveIterator SeekableIterator ).each do |str|
        TYPE_BY_NAME_STARTS_WITH[str] = 'SPL/Interfaces'
      end

      REPLACE_TYPES = {
        'Exceptions'        => 'SPL/Exceptions',
        'GD and Image'      => 'Image',
        'Gmagick'           => 'Image/GraphicsMagick',
        'Imagick'           => 'Image/ImageMagick',
        'Interfaces'        => 'SPL/Interfaces',
        'Iterators'         => 'SPL/Iterators',
        'mysqli'            => 'Database/MySQL',
        'PostgreSQL'        => 'Database/PostgreSQL',
        'Session'           => 'Sessions',
        'Session PgSQL'     => 'Database/PostgreSQL',
        'SQLite3'           => 'Database/SQLite',
        'SQLSRV'            => 'Database/SQL Server',
        'Stream'            => 'Streams',
        'Yaml'              => 'YAML' }

      TYPE_GROUPS = {
        'Classes and Functions' => ['Classes/Object', 'Function handling', 'Predefined Interfaces and Classes', 'runkit'],
        'Encoding'              => ['Gettext', 'iconv', 'Multibyte String'],
        'Compression'           => ['Bzip2', 'Zip', 'Zlib'],
        'Cryptography'          => ['Hash', 'Mcrypt', 'OpenSSL', 'Password Hashing'],
        'Database'              => ['DBA', 'ODBC', 'PDO'],
        'Date and Time'         => ['Calendar', 'Date/Time'],
        'Errors'                => ['Error Handling', 'Predefined Exceptions'],
        'File System'           => ['Directory', 'Fileinfo', 'Filesystem', 'Inotify'],
        'HTML'                  => ['DOM', 'Tidy'],
        'Language'              => ['Control Structures', 'Misc.', 'PHP Options/Info', 'Predefined Variables'],
        'Mail'                  => ['Mail', 'Mailparse'],
        'Mathematics'           => ['BC Math', 'Math', 'Statistic'],
        'Networking'            => ['GeoIP', 'Network', 'Output Control', 'SSH2', 'Socket', 'URL'],
        'Process Control'       => ['Eio', 'Libevent', 'POSIX', 'Program execution', 'pthreads'],
        'String'                => ['Ctype', 'PCRE', 'POSIX Regex', 'Taint'],
        'Variables'             => ['Filter', 'Variable handling'],
        'XML'                   => ['libxml', 'SimpleXML', 'XML Parser', 'XML-RPC', 'XMLReader', 'XMLWriter', 'XSLT'] }

      def get_name
        return 'IntlException' if slug == 'class.intlexception'
        name = css('> .sect1 > .title', 'h1', 'h2').first.content
        name.remove! 'The '
        name.sub! ' class', ' (class)'
        name.sub! ' interface', ' (interface)'
        name
      end

      def get_type
        type = at_css('.up').content.strip
        type = 'SPL/Iterators' if type.end_with? 'Iterator'
        type.remove! ' Functions'

        TYPE_BY_NAME_STARTS_WITH.each_pair do |key, value|
          break type = value if name.start_with?(key)
        end

        TYPE_GROUPS.each_pair do |replacement, types|
          types.each do |t|
            return replacement if type == t
          end
        end

        REPLACE_TYPES[type] || type
      end

      def include_default_entry?
        !initial_page? && doc.at_css('.reference', '.refentry', '.sect1')
      end
    end
  end
end
