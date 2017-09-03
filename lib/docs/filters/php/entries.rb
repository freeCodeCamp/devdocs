module Docs
  class Php
    class EntriesFilter < Docs::EntriesFilter
      TYPE_BY_NAME_STARTS_WITH = {
        'ArrayObject'     => 'SPL',
        'Collectable'     => 'pthreads',
        'Cond'            => 'pthreads',
        'CURL'            => 'cURL',
        'Date'            => 'Date/Time',
        'Ds'              => 'Data Structures',
        'ErrorException'  => 'Predefined Exceptions',
        'Exception'       => 'Predefined Exceptions',
        'Http'            => 'HTTP',
        'Json'            => 'JSON',
        'Lua'             => 'Lua',
        'Mutex'           => 'pthreads',
        'php_user_filter' => 'Stream',
        'Pool'            => 'pthreads',
        'QuickHash'       => 'Quickhash',
        'Reflector'       => 'Reflection',
        'Soap'            => 'SOAP',
        'SplFile'         => 'SPL/File',
        'SplTempFile'     => 'SPL/File',
        'Spl'             => 'SPL',
        'Stackable'       => 'pthreads',
        'Sync'            => 'Sync',
        'streamWrapper'   => 'Stream',
        'Thread'          => 'pthreads',
        'tidy'            => 'Tidy',
        'V8'              => 'V8Js',
        'Weak'            => 'Weakref',
        'Worker'          => 'pthreads',
        'XsltProcessor'   => 'XSLT',
        'Yar'             => 'Yar',
        'ZipArchive'      => 'Zip' }

      %w(APC Directory DOM Event Gearman Gmagick Imagick mysqli OAuth PDO Phar Reflection
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
        'APCu'              => 'APC',
        'Error'             => 'Errors',
        'Exceptions'        => 'SPL/Exceptions',
        'Exif'              => 'Image/Exif',
        'finfo'             => 'File System',
        'GD and Image'      => 'Image',
        'Gmagick'           => 'Image/GraphicsMagick',
        'Imagick'           => 'Image/ImageMagick',
        'Interfaces'        => 'SPL/Interfaces',
        'Iterators'         => 'SPL/Iterators',
        'mysqli'            => 'Database/MySQL',
        'PCRE Patterns'     => 'PCRE Reference',
        'PostgreSQL'        => 'Database/PostgreSQL',
        'Session'           => 'Sessions',
        'Session PgSQL'     => 'Database/PostgreSQL',
        'SQLite3'           => 'Database/SQLite',
        'SQLSRV'            => 'Database/SQL Server',
        'Stream'            => 'Streams',
        'Yaml'              => 'YAML' }

      TYPE_GROUPS = {
        'Classes and Functions' => ['Classes/Object', 'Function handling', 'Predefined Interfaces and Classes', 'runkit', 'Throwable'],
        'Encoding'              => ['Gettext', 'iconv', 'Multibyte String'],
        'Compression'           => ['Bzip2', 'Zip', 'Zlib'],
        'Cryptography'          => ['Hash', 'Mcrypt', 'OpenSSL', 'Password Hashing'],
        'Database'              => ['DBA', 'ODBC', 'PDO'],
        'Date and Time'         => ['Calendar', 'Date/Time'],
        'Errors'                => ['Error Handling', 'Predefined Exceptions'],
        'File System'           => ['Directory', 'Fileinfo', 'Filesystem', 'Inotify', 'Proctitle'],
        'HTML'                  => ['DOM', 'Tidy'],
        'Language'              => ['Control Structures', 'Misc.', 'PHP Options/Info', 'Predefined Variables'],
        'Mail'                  => ['Mail', 'Mailparse'],
        'Mathematics'           => ['BC Math', 'Math', 'Statistic'],
        'Networking'            => ['GeoIP', 'Network', 'Output Control', 'SSH2', 'Socket', 'URL'],
        'Process Control'       => ['Eio', 'Libevent', 'POSIX', 'Program execution', 'pthreads', 'PCNTL', 'Ev', 'Semaphore', 'Shared Memory', 'Sync'],
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
        return 'Language Reference' if subpath.start_with?('language.') || subpath.start_with?('functions.')
        return 'PCRE Reference' if subpath.start_with?('regexp.')

        type = at_css('.up').content.strip
        type = 'SPL/Iterators' if type.end_with? 'Iterator'
        type = 'Ev' if type =~ /\AEv[A-Z]/
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

      ALIASES = {
        'language.oop5.traits' => ['trait'],
        'language.operators.type' => ['instanceof'],
        'functions.user-defined' => ['function'],
        'language.oop5.visibility' => ['public', 'private', 'protected'],
        'language.references.whatdo' => ['=&'],
        'language.oop5.static' => ['static'],
        'language.oop5.interfaces' => ['interface', 'implements'],
        'language.oop5.inheritance' => ['extends'],
        'language.oop5.cloning' => ['clone', '__clone()'],
        'language.operators.logical' => ['and', 'or', 'xor'],
        'language.operators.increment' => ['++', '--'],
        'language.generators.syntax' => ['yield'],
        'language.oop5.final' => ['final'],
        'language.exceptions' => ['try', 'catch', 'finally'],
        'language.oop5.decon' => ['__construct()', '__destruct()'],
        'language.operators.comparison' => ['==', '===', '!=', '<>', '!==', '<=>'],
        'language.oop5.abstract' => ['abstract'],
        'language.operators.bitwise' => ['&', '|', '^', '~', '<<', '>>']
      }

      def additional_entries
        if aliases = ALIASES[slug]
          aliases.map { |a| [a] }
        elsif slug == 'language.constants.predefined'
          css('table tr[id]').map do |node|
            [node.at_css('code').content, node['id']]
          end
        elsif slug == 'language.oop5.magic'
          css('h3 a').map do |node|
            [node.content, node['href'][/#(.+)/, 1]]
          end
        elsif slug == 'language.oop5.overloading'
          css('.methodsynopsis[id]').map do |node|
            [node.at_css('.methodname').content + '()', node['id']]
          end
        else
          []
        end
      end

      def include_default_entry?
        !initial_page? && doc.at_css('.reference', '.refentry', '.sect1', '.simpara', '.para')
      end
    end
  end
end
